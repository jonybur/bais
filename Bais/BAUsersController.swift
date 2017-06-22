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

class BAUsersController: UIViewController, MosaicCollectionViewLayoutDelegate, CLLocationManagerDelegate,
	ASCollectionDataSource, ASCollectionDelegate, BAUsersCellNodeDelegate, BAUsersHeaderCellNodeDelegate {

	var contentToDisplay = [User]()
	var allUsers = [User]()
	var didFindLocation = false
	var showAllUsers = false

	let collectionNode: ASCollectionNode!
	let layoutInspector = MosaicCollectionViewLayoutInspector()
	let usersRef = FirebaseService.usersReference
	let locationManager = CLLocationManager()
	let activityIndicatorView = DGActivityIndicatorView(type: .ballScale,
	                                                    tintColor: ColorPalette.orangeLighter,
	                                                    size: 80)
	
	init (){
		let layout = MosaicCollectionViewLayout(startsAt: 10)
		layout.numberOfColumns = 2
		collectionNode = ASCollectionNode(frame: .zero, collectionViewLayout: layout)
		super.init(nibName: nil, bundle: nil)
		layout.delegate = self
		
		let activityIndicatorSize = (activityIndicatorView?.size)!
		activityIndicatorView!.frame = CGRect(x: (ez.screenWidth - activityIndicatorSize) / 2,
		                                      y: (ez.screenHeight - activityIndicatorSize) / 2,
		                                      width: activityIndicatorSize, height: activityIndicatorSize)
		
		extendedLayoutIncludesOpaqueBars = true
		
		collectionNode.dataSource = self;
		collectionNode.delegate = self;
		collectionNode.view.layoutInspector = layoutInspector
		collectionNode.backgroundColor = ColorPalette.white
		collectionNode.view.isScrollEnabled = true
		collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
	}
	
	required init(coder: NSCoder) {
		fatalError("Storyboards are not supported")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubnode(collectionNode!)
		self.view.addSubview(activityIndicatorView!);
		
		activityIndicatorView?.startAnimating()
		locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		locationManager.delegate = self
	}
	
	override func viewWillLayoutSubviews() {
		collectionNode.frame = self.view.bounds;
	}
	
	func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
		let user = contentToDisplay[indexPath.item]
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
		return contentToDisplay.count
	}
	
	func userForIndexPath(_ indexPath: IndexPath) -> User{
		return contentToDisplay[indexPath.item]
	}
	
//MARK: - LocationManager delegate methods
	
	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
		if(didFindLocation){
			return
		}
		if let location = locationManager.location?.coordinate {
			didFindLocation = true
			FirebaseService.updateUserLocation(location)
			observeUserLocation().then { location -> Void in
				CurrentUser.location = location
				self.populateUsers()
				self.observeFriends()
			} .catch { _ in }
		}
	}
	
	public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		let authorizationStatus = CLLocationManager.authorizationStatus()
		if (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways){
			locationManager.requestLocation()
		}
	}
	
	public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
		print("Location Manager failed with error")
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
			
			for user in allUsers {
				if (user.country == CurrentUser.user.country){
					let idxPath = IndexPath(item: countryToDisplay.count, section: 0)
					idxToReload.append(idxPath)
					countryToDisplay.append(user)
				}
			}
			
			if (idxToReload.count < allUsers.count){
				for idx in idxToReload.count...allUsers.count - 1{
					let idxPath = IndexPath(item: idx, section: 0)
					idxToDelete.append(idxPath)
				}
			}
			
			contentToDisplay = countryToDisplay.sorted { $0.distanceFromUser < $1.distanceFromUser }
			collectionNode.deleteItems(at: idxToDelete)
		} else {
			var idxToInsert = [IndexPath]()
			
			if (allUsers.count > 0){
				for idx in 0...allUsers.count - 1 {
					let idxPath = IndexPath(item: idx, section: 0)
					idxToReload.append(idxPath)
					
					if (idx > contentToDisplay.count - 1){
						idxToInsert.append(idxPath)
					}
				}
				contentToDisplay = allUsers.sorted { $0.distanceFromUser < $1.distanceFromUser }
				collectionNode.insertItems(at: idxToInsert)
			}
		}
		
		collectionNode.reloadItems(at: idxToReload)
		showAllUsers = !showAllUsers
	}
	
//MARK: - BAUsersViewCell delegate methods
	func usersCellNodeDidClickButton(_ usersViewCell: BAUsersCellNode) {
		guard let user = usersViewCell.user else { return }
		
		switch (user.friendshipStatus){
			case .noRelationship:
				FirebaseService.sendFriendRequestTo(friendId: user.id)
				usersViewCell.user.friendshipStatus = .invitationSent
				if usersViewCell.indexPath != nil{
					collectionNode.reloadItems(at: [usersViewCell.indexPath!])
				} else {
					print("IndexPath was nil")
				}
				break
			case .invitationSent:
				break
			case .invitationReceived:
				break
			case .accepted:
				FirebaseService.getSessionByUser(user.id).then(execute: { session -> Void in
					let chatController = BAChatController(with: session)
					self.navigationController?.pushViewController(chatController, animated: true)
				}).catch(execute: { _ in })
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
			let locationRef = FirebaseService.usersReference.child(FirebaseService.currentUserId).child("location")
			locationRef.observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot!) in
				if let locationArray = snapshot.value as? NSArray{
					let latitude = locationArray[0] as! Double
					let longitude = locationArray[1] as! Double
					fulfill(CLLocation(latitude: latitude, longitude: longitude))
				}
			})
		}
	}
	
	private func addUserAndReloadCollection(user: User){
		let idxOfAddedUser = addUserToOrderedArray(user: user)
		contentToDisplay = allUsers
		
		let idxPath = [IndexPath(item: contentToDisplay.count - 1, section: 0)]
		collectionNode.insertItems(at: idxPath)
		
		reloadItems(from: idxOfAddedUser)
	}
	
	private func reloadItems(from itemNumber: Int){
		var idxToReload = [IndexPath]()
		for idx in itemNumber...allUsers.count - 1 {
			let idxPath = IndexPath(item: idx, section: 0)
			idxToReload.append(idxPath)
		}
		collectionNode.reloadItems(at: idxToReload)
	}
	
	/*
	private func removeUserAndReloadCollection(userId: String){
		for (idx, user) in self.allUsers.enumerated(){
			if (user.id == userId){
				self.allUsers.remove(at: idx)
				return
			}
		}
	}
	*/
	
	// improve performance of this
	private func addUserToOrderedArray(user: User) -> Int{
		for (idx, usr) in allUsers.enumerated(){
			if (user.distanceFromUser < usr.distanceFromUser){
				allUsers.insert(user, at: idx)
				return idx
			}
		}
		
		allUsers.append(user)
		return 0
	}
	
	// gets all users (should filter by distance? paginate?)
	private func populateUsers(){
		let geoFire = GeoFire(firebaseRef: FirebaseService.locationsReference)
		
		observeUserLocation().then { userLocation -> Void in
			// radius of CABA == 8 km
			let kilometerRadius = 15.0
			let query = geoFire?.query(at: userLocation, withRadius: kilometerRadius)
			self.allUsers = [User]()
			
			// if a user enters the range, add to list
			query?.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
				if (key == FirebaseService.currentUserId){
                    return
				}
				
				self.getUserByKey(key!).then(execute: { user -> Promise<User> in
					return self.getFriendshipStatusFor(user: user)
				}).then(execute: { user -> Void in
					self.addUserAndReloadCollection(user: user)
					self.activityIndicatorView?.stopAnimating()
				}).catch(execute: { _ in })
			})
		}.catch { _ in }
	}
	
	private func observeFriends(){
		let userId = FirebaseService.currentUserId
		let userFriendsRef = FirebaseService.usersReference.child(userId).child("friends")
		
		userFriendsRef.observe(.childChanged, with: { snapshot in
			let friendStatus = FirebaseService.parseFriendStatus(from: snapshot)
			let userId = snapshot.key
			self.updateUserFriendshipStatusAndReloadCell(set: friendStatus, to: userId)
		})
		
		userFriendsRef.observe(.childAdded, with: { snapshot in
			let friendStatus = FirebaseService.parseFriendStatus(from: snapshot)
			let userId = snapshot.key
			self.updateUserFriendshipStatusAndReloadCell(set: friendStatus, to: userId)
		})
		
		userFriendsRef.observe(.childRemoved, with: { snapshot in
			let friendStatus: FriendshipStatus = .noRelationship
			let userId = snapshot.key
			self.updateUserFriendshipStatusAndReloadCell(set: friendStatus, to: userId)
		})
	}
	
	private func updateUserFriendshipStatusAndReloadCell(set friendshipStatus: FriendshipStatus, to userId: String){
		
		// update on both arrays
		for user in self.allUsers{
			if (user.id == userId){
				user.friendshipStatus = friendshipStatus
				break
			}
		}
		
		for (idx, user) in self.contentToDisplay.enumerated(){
			if (user.id == userId){
				user.friendshipStatus = friendshipStatus
				let idxPath = IndexPath(item: idx, section: 0)
				collectionNode.reloadItems(at: [idxPath])
				break
			}
		}
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
		collectionNode.dataSource = nil;
		collectionNode.delegate = nil;
	}
}

