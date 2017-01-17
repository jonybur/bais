//
//  BSWaterfallView.swift
//  Bais
//
//  Created by Rajeev Gupta on 11/9/16.
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree. An additional grant
//  of patent rights can be found in the PATENTS file in the same directory.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
//  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import AsyncDisplayKit
import FirebaseDatabase
import FirebaseAuth
import DGActivityIndicatorView
import PromiseKit

class BAUsersController: UIViewController, MosaicCollectionViewLayoutDelegate, ASCollectionDataSource, ASCollectionDelegate, BAUsersViewCellDelegate {

	var _sections = [[User]]()
	let _collectionNode: ASCollectionNode!
	let _layoutInspector = MosaicCollectionViewLayoutInspector()
	let usersRef = FIRDatabase.database().reference().child("users")
	let activityIndicatorView = DGActivityIndicatorView(type: .ballScale,
	                                                    tintColor: ColorPalette.baisOrange,
	                                                    size: 75)
	
	init (){
		let layout = MosaicCollectionViewLayout(startsAt: 10)
		layout.numberOfColumns = 2;
		layout.headerHeight = 44;
		_collectionNode = ASCollectionNode(frame: CGRect.zero, collectionViewLayout: layout)
		super.init(nibName: nil, bundle: nil);
		layout.delegate = self
		
		_collectionNode.dataSource = self;
		_collectionNode.delegate = self;
		_collectionNode.view.layoutInspector = _layoutInspector
		_collectionNode.backgroundColor = ColorPalette.baisBeige
		_collectionNode.view.isScrollEnabled = true
		_collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
	}
	
	required init(coder: NSCoder) {
		fatalError("NSCoding not supported")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubnode(_collectionNode!)
		self.view.addSubview(activityIndicatorView!);
		
		activityIndicatorView?.startAnimating()
		
		observeUserLocation().then { location -> Void in
			CurrentUser.location = location
			self.populateUsers()
		}
	}

	deinit {
		_collectionNode.dataSource = nil;
		_collectionNode.delegate = nil;
	}
	
	private func observeUserLocation() -> Promise<CLLocation>{
		return Promise{ fulfill, reject in
			let locationRef = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("location");
			locationRef.observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot!) in
				if let dict = snapshot.value as? NSDictionary{
					let latitude = dict["lat"] as! Double
					let longitude = dict["lon"] as! Double
					fulfill(CLLocation(latitude: latitude, longitude: longitude))
				}
			});
		}
	}
	
	var stop: Bool = false
	
	// move this
	private func populateUsers(){
		let activityIndicatorSize = (activityIndicatorView?.size)!
		activityIndicatorView!.frame = CGRect(x: (ez.screenWidth - activityIndicatorSize) / 2,
		                                      y: (ez.screenHeight - activityIndicatorSize) / 2,
		                                      width: activityIndicatorSize, height: activityIndicatorSize);
		
		usersRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot!) in
			if let snapshotDictionary = snapshot.value as? NSDictionary{
				// sets a new section
				
				var nationalityMap = [String: Int]()
				
				var promises: [Promise<Bool>] = [Promise<Bool>]()
				
				for _ in 0...0{
					for (_, snapshotValue) in snapshotDictionary{
						if let userDictionary = snapshotValue as? NSDictionary{
							
							let user = User(fromNSDictionary: userDictionary)
							promises.append(self.getFriendshipStatusFor(user: user))
							
							if let nationalitySection = nationalityMap[user.nationality]{
								// adds user to proper section
								self._sections[nationalitySection].append(user)
							} else {
								// new nationality, add section
								self._sections.append([])
								self._sections[self._sections.count - 1].append(user)
								// add nationality to map
								nationalityMap.updateValue(self._sections.count - 1, forKey: user.nationality)
							}
							
						}
					}
				}
				
				when(resolved: promises).then(execute: { _ -> Void in
					self._collectionNode.reloadData()
					self.activityIndicatorView?.stopAnimating()
				})
				
				
			}
			
		}
	}
	
	
	private func getFriendshipStatusFor(user: User) -> Promise<Bool>{
		
		return Promise{ fulfill, reject in
			// query to friend relationship
			let relationshipQuery = FIRDatabase.database().reference().child("users")
				.child((FIRAuth.auth()?.currentUser?.uid)!).child("friends").child(user.id)
			
			relationshipQuery.observe(.value) { (snapshot: FIRDataSnapshot!) in
				
				if let relationship = snapshot.value as? NSDictionary{
					let status = relationship["status"] as! String
					user.friendshipStatus = FriendshipStatus(rawValue: status)!
				} else {
					user.friendshipStatus = .noRelationship
				}
				
				fulfill(true)
			}
		}
	}

	
	override func viewWillLayoutSubviews() {
		_collectionNode.frame = self.view.bounds;
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
		let user = _sections[indexPath.section][indexPath.item]
		let node = BAUsersViewCell(with: user)
		node.delegate = self
		node.cornerRadius = 10
		return node
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
		let textAttributes : NSDictionary = [
			NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline),
			NSForegroundColorAttributeName: UIColor.gray
		]
		let textInsets = UIEdgeInsets(top: 11, left: 0, bottom: 11, right: 0)
		let textCellNode = ASTextCellNode(attributes: textAttributes as! [AnyHashable : Any], insets: textInsets)
		let user = self.userForIndexPath(indexPath)
		textCellNode.text = String(format: user.nationality, indexPath.section + 1)
		return textCellNode
	}
	
	func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
		return _sections.count
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
		return _sections[section].count
	}
	
	func userForIndexPath(_ indexPath: IndexPath) -> User{
		return _sections[indexPath.section][indexPath.item]
	}
	
	internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
		let user = self.userForIndexPath(originalItemSizeAtIndexPath)
		let ratio = user.imageRatio
		return CGSize(width: 1, height: ratio)
	}
	
	//MARK: - BAUsersViewCell delegate methods
	func usersViewCellDidClickButton(_ usersViewCell: BAUsersViewCell) {
		let indexPath = self._collectionNode.indexPath(for: usersViewCell)!
		let user = self.userForIndexPath(indexPath)
		usersViewCell.setFriendshipAction()
		
		print (user.friendshipStatus)
		switch (user.friendshipStatus){
			case .noRelationship:
				FirebaseAPI.sendFriendRequestTo(friendId: user.id)
				break;
			case .invited:
				break;
			case .accepted:
				self.navigationController?.pushViewController(BAChatController(withUser: user), animated: true)
				break;
			default:
				break;
		}
		
		
	}
	
	func usersViewCellDidClickView(_ usersViewCell: BAUsersViewCell) {
		print ("taps on card")
	}
}

