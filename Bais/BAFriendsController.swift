//
//  BATableController.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 18/1/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase
import PromiseKit

enum ChatDisplayMode: String{
	case friends = "friends", requests = "requests"
	
	func next() -> ChatDisplayMode {
		switch self {
		case .friends:
			return .requests
		case .requests:
			return .friends
		}
	}
}

final class BAFriendsController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, BAChatHeaderCellNodeDelegate, BAFriendRequestCellNodeDelegate {
	
	// change this to one user array _usersToDisplay with two pointer arrays _friends and _requests
	// also, change this to dictionaries String:User
	var _usersToDisplay = [User]()
	var _friends = [User]()
	var _requests = [User]()
	var displayMode: ChatDisplayMode!
	
	var tableNode: ASTableNode {
		return node as! ASTableNode
	}
	
	init() {
		super.init(node: ASTableNode())
		tableNode.delegate = self
		tableNode.dataSource = self
		tableNode.view.separatorStyle = .none
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("Storyboards are not supported")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.observeFriends()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
//MARK: - ASTableNode didSelectRowAt
	
	func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
		if (indexPath.item == 0){
			return
		}
		
		let user = _usersToDisplay[indexPath.item - 1]
		
		if (displayMode == .requests){
			// taps request
			self.navigationController?.pushViewController(BAProfileController(with: user), animated: true)
			self.tableNode.deselectRow(at: indexPath, animated: true)
			return
		}
		
		// taps friend (opens chat)
		self.navigationController?.pushViewController(BAChatController(with: user), animated: true)
		self.tableNode.deselectRow(at: indexPath, animated: true)
	}
	
//MARK: - ASTableNode data source and delegate.
	
	func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		let item = indexPath.item
		
		if (item == 0){
			let headerNode = BAChatHeaderCellNode(with: displayMode)
			headerNode.delegate = self
			return headerNode
		}
		
		let user = _usersToDisplay[item - 1]
		
		if (displayMode == .requests){
			let chatNode = BAFriendRequestCellNode(with: user)
			chatNode.delegate = self
			return chatNode
		}
		
		let chatNode = BAChatCellNode(with: user)
		return chatNode
	}
	
	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		if (displayMode != nil){
			return self._usersToDisplay.count > 0 ? self._usersToDisplay.count + 1 : 1
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if (indexPath.item == 0 || displayMode == .friends){
			return false
		}
		return true
	}
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let removeAction = UITableViewRowAction(style: .normal, title: "Reject") { (rowAction, indexPath) in
			// TODO kill request
			FirebaseService.denyFriendRequestFrom(friendId: self._usersToDisplay[indexPath.item - 1].id)
		}
		removeAction.backgroundColor = ColorPalette.orange
		return [removeAction]
	}
	
//MARK: - BAFriendRequestCellNodeDelegate methods
	
	func friendRequestCellNodeAcceptedInvitation(_ friendRequestCellNode: BAFriendRequestCellNode) {
		FirebaseService.acceptFriendRequestFrom(friendId: friendRequestCellNode.cardUser.id)
	}
	
//MARK: - BAChatHeaderCellNodeDelegate
	
	func chatHeaderCellNodeDidClickButton(_ chatViewCell: BAChatHeaderCellNode) {
		displayMode = displayMode?.next()
		
		if (displayMode == .requests){
			_usersToDisplay = _requests
		} else if (displayMode == .friends){
			_usersToDisplay = _friends
		}
		
		// adds the header to the final count
		let elementsToDisplay = _usersToDisplay.count + 1
		// current row count
		let tableRows = tableNode.numberOfRows(inSection: 0)
		
		if (tableRows < elementsToDisplay){
			// need to add more rows to make up for elementsToDisplay
			var idxToInsert = [IndexPath]()
			for idx in tableRows...elementsToDisplay-1{
				let idxPath = IndexPath(item:idx, section:0)
				idxToInsert.append(idxPath)
			}
			tableNode.insertRows(at: idxToInsert, with: .fade)
		} else if (elementsToDisplay < tableRows){
			// need to remove rows to make up for elementsToDisplay
			var idxToRemove = [IndexPath]()
			for idx in elementsToDisplay...tableRows - 1{
				let idxPath = IndexPath(item:idx, section:0)
				idxToRemove.append(idxPath)
			}
			tableNode.deleteRows(at: idxToRemove, with: .fade)
		}
		
		var idxToReload = [IndexPath]()
		if (elementsToDisplay > 1){
			for idx in 1...elementsToDisplay-1{
				let idxPath = IndexPath(row: idx, section: 0)
				idxToReload.append(idxPath)
			}
		}
		tableNode.reloadRows(at: idxToReload, with: .fade)
	}
	
//MARK: - Firebase
	
	// gets friends and reloads table after getting all information
	private func observeFriends() {
		let userId = FirebaseService.currentUserId
		let userFriendsRef = FirebaseService.usersReference.child(userId).child("friends")
		
		userFriendsRef.observe(.childChanged) { (snapshot: FIRDataSnapshot!) in
			let userId = snapshot.key
			let status = self.parseFriendStatus(from: snapshot)
			
			// if status is accepted, move to friends, remove from requests
			if (status == .accepted){
				for (idx, user) in self._requests.enumerated(){
					if (user.id == userId){
						self._friends.append(user)
						self._requests.remove(at: idx)
						self.selectDisplayMode()
						return
					}
				}
			}
			
		}
		userFriendsRef.observe(.childMoved) { (snapshot: FIRDataSnapshot!) in
			print("moved")
		}
		userFriendsRef.observe(.childRemoved) { (snapshot: FIRDataSnapshot!) in
			print("removed")
		}
		userFriendsRef.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
			// promises get resolved when all users are complete
			self.getSingleUser(from: snapshot).then(execute: { user -> Void in
				// got user
				if (user.friendshipStatus == .accepted){
					self._friends.append(user)
				} else if (user.friendshipStatus == .invitationReceived){
					self._requests.append(user)
				}
				self.selectDisplayMode()
			}).catch(execute: { _ in })
		}
	}
	
	private func selectDisplayMode(){
		
		if (_friends.count == 0 && _requests.count == 0){
			// show empty message
		} else if (_friends.count == 0){
			// show requests
			_usersToDisplay = _requests
			displayMode = .requests
		} else if (_requests.count == 0){
			// show friends
			_usersToDisplay = _friends
			displayMode = .friends
		}
		
		tableNode.reloadData()
	}
	
	// refactor this
	private func getSingleUser(from relationshipSnapshot: FIRDataSnapshot) -> Promise<User>{
		return Promise{ fulfill, reject in
			let status = parseFriendStatus(from: relationshipSnapshot)
			let friendId = String(describing: relationshipSnapshot.key)
			
			if (status == .accepted || status == .invitationReceived) {
				// if it's a friend, or was invited by someone, create the chat card
				self.getUser(with: friendId).then(execute: { user -> Void in
					// get user
					user.friendshipStatus = status
					fulfill(user)
				}).catch(execute: { _ in })
			}
		}
	}
	
	private func parseFriendStatus(from relationshipSnapshot: FIRDataSnapshot) -> FriendshipStatus{
		guard let relationshipAttributes = relationshipSnapshot.value as? NSDictionary else { return .undefined }

		let relationshipStatus = relationshipAttributes["status"] as! String
		let relationshipPostedBy = relationshipAttributes["postedBy"] as! String
		var status: FriendshipStatus = .undefined
		
		if (relationshipStatus == "invited"){
			if (relationshipPostedBy == FirebaseService.currentUserId){
				status = .invitationSent
			} else {
				status = .invitationReceived
			}
		} else if (relationshipStatus == "accepted"){
			status = .accepted
		}
		
		return status
	}

	private func getUser(with userId: String) -> Promise<User>{
		return Promise{ fulfill, reject in
			let userQuery = FirebaseService.usersReference.child(userId)
			userQuery.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot!) in
				if let userDictionary = snapshot.value as? NSDictionary{
					let user = User(fromNSDictionary: userDictionary)
					fulfill(user)
				}
			}
		}
	}
	
	private func observeLastMessage(of userId: String){
		// queries to last message
		let messageQuery = FirebaseService.messagesReference.child(FirebaseService.currentUserId).child(userId).queryLimited(toLast: 1)
		messageQuery.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
			if let message = snapshot.value as? NSDictionary{
				let messageString = message["text"] as! String
				for (idx, user) in self._usersToDisplay.enumerated(){
					if (user.id == userId){
						user.lastMessage = messageString
						self.tableNode.reloadRows(at: [IndexPath(item: idx + 1, section: 0)], with: .fade)
						return
					}
				}
			}
		}
	}
	
	
}
