//
//  BAUsersController.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 18/1/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import FirebaseDatabase
import FirebaseAuth
import Hero
import DGActivityIndicatorView
import PromiseKit
import GeoFire

class BAUsersController: UIViewController, MosaicCollectionViewLayoutDelegate,
	ASCollectionDataSource, ASCollectionDelegate, BAUsersCellNodeDelegate, BAUsersHeaderCellNodeDelegate {

	var _contentToDisplay = [User]()
	var _allUsers = [User]()
	var showAllUsers: Bool = false

	let _collectionNode: ASCollectionNode!
	let _layoutInspector = MosaicCollectionViewLayoutInspector()
	let usersRef = FirebaseService.usersReference
	let activityIndicatorView = DGActivityIndicatorView(type: .ballScale,
	                                                    tintColor: ColorPalette.orange,
	                                                    size: 75)
	
	init (){
		let layout = MosaicCollectionViewLayout(startsAt: 10)
		layout.numberOfColumns = 2;
		_collectionNode = ASCollectionNode(frame: .zero, collectionViewLayout: layout)
		super.init(nibName: nil, bundle: nil);
		layout.delegate = self
		
		extendedLayoutIncludesOpaqueBars = true
		isHeroEnabled = true
		
		_collectionNode.dataSource = self;
		_collectionNode.delegate = self;
		_collectionNode.view.layoutInspector = _layoutInspector
		_collectionNode.backgroundColor = ColorPalette.white
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
		} .catch { _ in }
	}
	
	override func viewWillLayoutSubviews() {
		_collectionNode.frame = self.view.bounds;
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
		let user = _contentToDisplay[indexPath.item]
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
		return 1
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
		return _contentToDisplay.count
	}
	
	func userForIndexPath(_ indexPath: IndexPath) -> User{
		return _contentToDisplay[0]
	}
	
	//MARK: - MosaicCollectionViewLayoutDelegate delegate methods
	internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
		let user = self.userForIndexPath(originalItemSizeAtIndexPath)
		let ratio = user.imageRatio
		return CGSize(width: 1, height: ratio)
	}
	
	//MARK: - BAUsersHeaderViewCell delegate methods
	func usersHeaderCellNodeDidClickButton(_ usersHeaderViewCell: BAUsersHeaderCellNode) {
		
		var idxToReload = [IndexPath]()
		
		if (!showAllUsers){
			var countryToDisplay = [User]()
			var idxToDelete = [IndexPath]()
			
			for user in _allUsers {
				if (user.nationality == "Spain"){
					let idxPath = IndexPath(item: countryToDisplay.count, section: 0)
					idxToReload.append(idxPath)
					countryToDisplay.append(user)
				}
			}
			for idx in idxToReload.count..._allUsers.count - 1{
				let idxPath = IndexPath(item: idx, section: 0)
				idxToDelete.append(idxPath)
			}
			
			_contentToDisplay = countryToDisplay.sorted { $0.distanceFromUser < $1.distanceFromUser }
			_collectionNode.deleteItems(at: idxToDelete)
		} else {
			var idxToInsert = [IndexPath]()
			
			for idx in 0..._allUsers.count - 1 {
				let idxPath = IndexPath(item: idx, section: 0)
				idxToReload.append(idxPath)
				
				if (idx > _contentToDisplay.count - 1){
					idxToInsert.append(idxPath)
				}
			}
			
			_contentToDisplay = _allUsers.sorted { $0.distanceFromUser < $1.distanceFromUser }
			_collectionNode.insertItems(at: idxToInsert)
		}
		
		_collectionNode.reloadItems(at: idxToReload)
		showAllUsers = !showAllUsers
	}
	
	//MARK: - BAUsersViewCell delegate methods
	func usersCellNodeDidClickButton(_ usersViewCell: BAUsersCellNode) {
		let indexPath = self._collectionNode.indexPath(for: usersViewCell)!
		let user = self.userForIndexPath(indexPath)
		usersViewCell.setFriendshipAction()
		
		switch (user.friendshipStatus){
			case .noRelationship:
				FirebaseService.sendFriendRequestTo(friendId: user.id)
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
		let user = usersViewCell.user
		let controller = BAProfileController(with: user!)
		self.navigationController?.pushViewController(controller, animated: false)
	}
	
	//MARK: - Firebase
	// gets current user location
	private func observeUserLocation() -> Promise<CLLocation>{
		return Promise{ fulfill, reject in
			let locationRef = FirebaseService.usersReference.child(FirebaseService.currentUserId).child("location");
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
		
		let geoFire = GeoFire(firebaseRef: FirebaseService.rootReference)
		let locationRef = FirebaseService.usersReference.child(FirebaseService.currentUserId).child("location")
		
		observeUserLocation().then { userLocation -> Void in
			let kilometerRadius: Double = 10
			let query = geoFire?.query(at: userLocation, withRadius: kilometerRadius)
			
			query?.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
				// TODO implement user fetching from here
			})
		}.catch { _ in }
		
		// TODO: move this inside geoFire query
		usersRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot!) in
			if let snapshotDictionary = snapshot.value as? NSDictionary{

				// sets a new section				
				var promises = [Promise<Void>]()
				self._allUsers = [User]()
				
				for _ in 0...0{
					for (_, snapshotValue) in snapshotDictionary{
						if let userDictionary = snapshotValue as? NSDictionary{
							let user = User(fromNSDictionary: userDictionary)
							if (user.id == FirebaseService.currentUserId){
								continue;
							}
							promises.append(self.getFriendshipStatusFor(user: user))
							self._allUsers.append(user)
						}
					}
				}
			
				when(resolved: promises).then(execute: { _ -> Void in
					self._contentToDisplay = self._allUsers.sorted { $0.distanceFromUser < $1.distanceFromUser }
					
					// change reload data to something else?
					self._collectionNode.reloadSections(IndexSet(integer:0))
					//self._collectionNode.view.contentOffset = CGPoint(x: 0, y: 75)
					self.activityIndicatorView?.stopAnimating()
				}).catch(execute: { _ in })
			}
			
		}
	}
	
	// get friendship status of user
	private func getFriendshipStatusFor(user: User) -> Promise<Void>{
		
		return Promise{ fulfill, reject in
			// query to friend relationship
			let relationshipQuery = FirebaseService.usersReference
				.child(FirebaseService.currentUserId).child("friends").child(user.id)
			
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

