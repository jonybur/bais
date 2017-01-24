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

class BAUsersController: UIViewController, MosaicCollectionViewLayoutDelegate,
	ASCollectionDataSource, ASCollectionDelegate, BAUsersCellNodeDelegate, BAUsersHeaderCellNodeDelegate {

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
		_collectionNode = ASCollectionNode(frame: .zero, collectionViewLayout: layout)
		super.init(nibName: nil, bundle: nil);
		layout.delegate = self
		
		self.extendedLayoutIncludesOpaqueBars = true
		
		_collectionNode.dataSource = self;
		_collectionNode.delegate = self;
		_collectionNode.view.layoutInspector = _layoutInspector
		_collectionNode.backgroundColor = ColorPalette.baisWhite
		_collectionNode.view.isScrollEnabled = true
		_collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
	}
	
	required init(coder: NSCoder) {
		fatalError("Storyboards are not supported")
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
	
	override func viewWillLayoutSubviews() {
		_collectionNode.frame = self.view.bounds;
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
		let user = _sections[indexPath.section][indexPath.item]
		let node = BAUsersCellNode(with: user)
		node.delegate = self
		return node
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
		let header = BAUsersHeaderCellNode()
		header.delegate = self
		return header
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
	
	//MARK: - BAUsersHeaderViewCell delegate methods
	func usersHeaderCellNodeDidClickButton(_ usersHeaderViewCell: BAUsersHeaderCellNode) {
		print("stop!")
	}
	
	//MARK: - BAUsersViewCell delegate methods
	func usersCellNodeDidClickButton(_ usersViewCell: BAUsersCellNode) {
		let indexPath = self._collectionNode.indexPath(for: usersViewCell)!
		let user = self.userForIndexPath(indexPath)
		usersViewCell.setFriendshipAction()
		
		switch (user.friendshipStatus){
			case .noRelationship:
				FirebaseAPI.sendFriendRequestTo(friendId: user.id)
				break;
			case .invited:
				break;
			case .accepted:
				self.navigationController?.pushViewController(BAChatController(with: user), animated: true)
				break;
			default:
				break;
		}
	}
	
	func usersCellNodeDidClickView(_ usersViewCell: BAUsersCellNode) {
		print ("taps on card")
	}
	
	//MARK: - Firebase
	
	// gets current user location
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
	
	
	// gets all users (should filter by distance? paginate?)
	private func populateUsers(){
		let activityIndicatorSize = (activityIndicatorView?.size)!
		activityIndicatorView!.frame = CGRect(x: (ez.screenWidth - activityIndicatorSize) / 2,
		                                      y: (ez.screenHeight - activityIndicatorSize) / 2,
		                                      width: activityIndicatorSize, height: activityIndicatorSize);
		
		usersRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot!) in
			if let snapshotDictionary = snapshot.value as? NSDictionary{

				// sets a new section				
				var promises = [Promise<Void>]()
				self._sections.append([])
				
				for _ in 0...2{
					for (_, snapshotValue) in snapshotDictionary{
						if let userDictionary = snapshotValue as? NSDictionary{
							let user = User(fromNSDictionary: userDictionary)
							if (user.id == FIRAuth.auth()?.currentUser?.uid){
								continue;
							}
							promises.append(self.getFriendshipStatusFor(user: user))
							self._sections[0].append(user)
						}
					}
				}
			
				when(resolved: promises).then(execute: { _ -> Void in
					self._sections[0] = self._sections[0].sorted { $0.distanceFromUser < $1.distanceFromUser }
					self._collectionNode.reloadData()
					//self._collectionNode.view.contentOffset = CGPoint(x: 0, y: 75)
					self.activityIndicatorView?.stopAnimating()
				})
				
				
			}
			
		}
	}
	
	// get friendship status of user
	private func getFriendshipStatusFor(user: User) -> Promise<Void>{
		
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
				
				fulfill()
			}
		}
	}
	
	//MARK: - Dealloc
	deinit {
		_collectionNode.dataSource = nil;
		_collectionNode.delegate = nil;
	}
}

