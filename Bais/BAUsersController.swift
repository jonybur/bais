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
		
		let activityIndicatorSize = (activityIndicatorView?.size)!
		activityIndicatorView!.frame = CGRect(x: (ez.screenWidth - activityIndicatorSize) / 2,
		                                      y: (ez.screenHeight - activityIndicatorSize) / 2,
		                                      width: activityIndicatorSize, height: activityIndicatorSize);
		
		extendedLayoutIncludesOpaqueBars = true
		
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
			self.observeFriends()
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
		let header = BAUsersHeaderCellNode(with: CurrentUser.user.country)
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
		return _contentToDisplay[indexPath.item]
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
				if (user.country == CurrentUser.user.country){
					let idxPath = IndexPath(item: countryToDisplay.count, section: 0)
					idxToReload.append(idxPath)
					countryToDisplay.append(user)
				}
			}
			
			if (idxToReload.count < _allUsers.count){
				for idx in idxToReload.count..._allUsers.count - 1{
					let idxPath = IndexPath(item: idx, section: 0)
					idxToDelete.append(idxPath)
				}
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
		guard let user = usersViewCell.user else { return }
		
		switch (user.friendshipStatus){
			case .noRelationship:
				FirebaseService.sendFriendRequestTo(friendId: user.id)
				usersViewCell.user.friendshipStatus = .invitationSent
				_collectionNode.reloadItems(at: [usersViewCell.indexPath!])
				break
			case .invitationSent:
				break
			case .invitationReceived:
				break
			case .accepted:
				//let chatController = BAChatController(with: user)
				//navigationController?.pushViewController(chatController, animated: true)
				break
			default:
				break
		}
	}
	
	func usersCellNodeDidClickView(_ usersViewCell: BAUsersCellNode) {
		guard let user = usersViewCell.user else { return }
		
		let controller = BAProfileController(with: user)
		navigationController?.pushViewController(controller, animated: true)
	}
	
	//MARK: - Firebase
	// gets current user location
	private func observeUserLocation() -> Promise<CLLocation>{
		return Promise{ fulfill, reject in
			let locationRef = FirebaseService.usersReference.child(FirebaseService.currentUserId).child("location");
			locationRef.observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot!) in
				if let locationArray = snapshot.value as? NSArray{
					let latitude = locationArray[0] as! Double
					let longitude = locationArray[1] as! Double
					fulfill(CLLocation(latitude: latitude, longitude: longitude))
				}
			});
		}
	}
	
	private func resortElementsAndReloadView(){
		self._contentToDisplay = self._allUsers.sorted { $0.distanceFromUser < $1.distanceFromUser }
		self._collectionNode.reloadSections(IndexSet(integer:0))
	}
	
	// gets all users (should filter by distance? paginate?)
	private func populateUsers(){
		let geoFire = GeoFire(firebaseRef: FirebaseService.locationsReference)
		
		observeUserLocation().then { userLocation -> Void in
			let kilometerRadius: Double = 10
			let query = geoFire?.query(at: userLocation, withRadius: kilometerRadius)
			self._allUsers = [User]()
			
			// if a user enters the range, add to list
			query?.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
				if (key == FirebaseService.currentUserId){
					return
				}
				
				self.getUserByKey(key!).then(execute: { user -> Promise<User> in
					return self.getFriendshipStatusFor(user: user)
				}).then(execute: { user -> Void in
					self._allUsers.append(user)
					self.resortElementsAndReloadView()
					self.activityIndicatorView?.stopAnimating()
				}).catch(execute: { _ in })
			})
			
			// if a user leaves the range, remove from list
			query?.observe(.keyExited, with: { (key: String?, location: CLLocation?) in
				for (idx, user) in self._allUsers.enumerated(){
					if (user.id == key){
						self._allUsers.remove(at: idx)
						self.resortElementsAndReloadView()
						return
					}
				}
			})
		}.catch { _ in }
	}
	
	private func observeFriends(){
		let userId = FirebaseService.currentUserId
		let userFriendsRef = FirebaseService.usersReference.child(userId).child("friends")
		
		userFriendsRef.observe(.childChanged, with: { snapshot in
			guard let dictionary = snapshot.value as? NSDictionary else { return }
			print("friend changed " + String(describing: dictionary))
		})
		
		userFriendsRef.observe(.childAdded, with: { snapshot in
			guard let dictionary = snapshot.value as? NSDictionary else { return }
			print("friend added " + String(describing: dictionary))
		})
	}
	
	// get user by userId
	private func getUserByKey(_ userId: String) -> Promise<User>{
		return Promise{ fulfill, reject in
			usersRef.child(userId).observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot!) in
				let user = User(from: snapshot)
				fulfill(user)
			}
		}
	}
	
	// get friendship status of user
	private func getFriendshipStatusFor(user: User) -> Promise<User>{
		
		return Promise{ fulfill, reject in
			// query to friend relationship
			let relationshipQuery = FirebaseService.usersReference
				.child(FirebaseService.currentUserId).child("friends").child(user.id)
			
			relationshipQuery.observe(.value) { (snapshot: FIRDataSnapshot!) in
				user.friendshipStatus = FirebaseService.parseFriendStatus(from: snapshot)
				fulfill(user)
			}
		}
	}
	
	//MARK: - Dealloc
	deinit {
		_collectionNode.dataSource = nil;
		_collectionNode.delegate = nil;
	}
}

