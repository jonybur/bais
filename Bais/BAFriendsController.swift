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
	case sessions = "sessions", requests = "requests"
	
	func next() -> ChatDisplayMode {
		switch self {
		case .sessions:
			return .requests
		case .requests:
			return .sessions
		}
	}
}

final class BAFriendsController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, BAChatHeaderCellNodeDelegate, BAFriendRequestCellNodeDelegate {
	
	// change this to one user array _usersToDisplay with two pointer arrays _friends and _requests
	// also, change this to dictionaries String:User
	//var _usersToDisplay = [User]()
	var _sessions = [Session]()
	var _requests = [User]()
	var emptyStateNode: BAEmptyStateCellNode!
	var displayMode: ChatDisplayMode = .sessions//: ChatDisplayMode!
	//var showEmptyState = false
	
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
		observeFriends()
		
		emptyStateNode = BAEmptyStateCellNode(title: "You don't have any\nfriend requests.")
		emptyStateNode.frame = CGRect(x: 0, y: 150, width: ez.screenWidth, height: ez.screenHeight - 300)
		super.node.addSubnode(emptyStateNode)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
//MARK: - ASTableNode didSelectRowAt
	
	func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
		if (indexPath.item == 0){
			return
		}
		
		if (displayMode == .requests){
			// taps request
			let user = _requests[indexPath.item - 1]
			self.navigationController?.pushViewController(BAProfileController(with: user), animated: true)
			self.tableNode.deselectRow(at: indexPath, animated: true)
			return
		}
		
		// taps friend (opens chat)
		let session = _sessions[indexPath.item - 1]
		self.navigationController?.pushViewController(BAChatController(with: session), animated: true)
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
		
		if (displayMode == .requests){
			let user = _requests[item - 1]
			let chatNode = BAFriendRequestCellNode(with: user)
			chatNode.delegate = self
			return chatNode
		}
		
		let session = _sessions[item - 1]
		let chatNode = BAChatCellNode(with: session)
		return chatNode
	}
	
	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		var rowCount = 0
		
		// gets item count (includes header)
		if (displayMode == .requests){
			rowCount = _requests.count > 0 ? _requests.count + 1 : 1
		} else if (displayMode == .sessions){
			rowCount = _sessions.count > 0 ? _sessions.count + 1 : 1
		}
		
		// if only got header back, then should show empty state cell node
		emptyStateNode.alpha = rowCount == 1 ? 1 : 0
		
		// return normal count
		return rowCount
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if (indexPath.item == 0 || displayMode == .sessions){
			return false
		}
		return true
	}
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let removeAction = UITableViewRowAction(style: .normal, title: "Reject") { (rowAction, indexPath) in
			// TODO kill request
			FirebaseService.denyFriendRequestFrom(friendId: self._requests[indexPath.item - 1].id)
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
		displayMode = displayMode.next()
		
		// adds the header to the final count
		
		var elementsToDisplay = 0
		if (displayMode == .requests){
			elementsToDisplay = _requests.count + 1
		} else if (displayMode == .sessions){
			elementsToDisplay = _sessions.count + 1
		}
		
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
		
		// user friends
		let userId = FirebaseService.currentUserId
		let userFriendsRef = FirebaseService.usersReference.child(userId).child("friends")
		
		userFriendsRef.observe(.childChanged) { (snapshot: FIRDataSnapshot!) in
			let userId = snapshot.key
			let status = FirebaseService.parseFriendStatus(from: snapshot)
			
			// if status is accepted, remove from requests
			if (status == .accepted){
				for (idx, user) in self._requests.enumerated(){
					if (user.id == userId){
						self._requests.remove(at: idx)
						if (self.displayMode == .requests){
							let idxPath = IndexPath(row: idx + 1, section: 0)
							self.tableNode.deleteRows(at: [idxPath], with: .fade)
						}
						return
					}
				}
			}
			
		}
		userFriendsRef.observe(.childMoved) { (snapshot: FIRDataSnapshot!) in
			print("moved")
		}
		userFriendsRef.observe(.childRemoved) { (snapshot: FIRDataSnapshot!) in
			for (idx, request) in self._requests.enumerated(){
				if (request.id == snapshot.key){
					self._requests.remove(at: idx)
					if(self.displayMode == .requests){
						let idxPath = IndexPath(row: idx + 1, section: 0)
						self.tableNode.deleteRows(at: [idxPath], with: .fade)
					}
					return
				}
			}
			
		}
		userFriendsRef.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
			// promises get resolved when all users are complete
			FirebaseService.getUserFromRelationship(from: snapshot).then(execute: { user -> Void in
				// got user
				if (user.friendshipStatus == .invitationReceived){
					self._requests.append(user)
					if (self.displayMode == .requests){
						// add new row to section
						let idxPath = IndexPath(row: self._requests.count, section: 0)
						self.tableNode.insertRows(at: [idxPath], with: .fade)
					}
				}
			}).catch(execute: { _ in })
		}
		
		// user sessions
		let userSessionsRef = FirebaseService.usersReference.child(userId).child("sessions")
		userSessionsRef.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
			
			// this is optional, but it checks that the session being added "active" is set to true
			guard let sessionValues = snapshot.value as? NSDictionary else { return }
			guard let sessionIsActive = sessionValues["active"] as? Bool else { return }
			if (!sessionIsActive){
				return
			}
			
			// adds to screen
			FirebaseService.getSession(from: snapshot.key).then(execute: { session -> Void in
				guard let unreadCount = sessionValues["unread_count"] as? Int else { return }
				session.unreadCount = unreadCount
				self.observeLastMessage(of: session.id)
				self._sessions.append(session)
				if(self.displayMode == .sessions){
					// add new row to section
					let idxPath = IndexPath(row: self._sessions.count, section: 0)
					self.tableNode.insertRows(at: [idxPath], with: .fade)
				}
			}).catch(execute: { _ in })
		}
	
		userSessionsRef.observe(.childChanged) { (snapshot: FIRDataSnapshot!) in
			
			// checks if session activity was turned to false
			guard let sessionValues = snapshot.value as? NSDictionary else { return }
			guard let sessionIsActive = sessionValues["active"] as? Bool else { return }
			if (sessionIsActive){
				// should update the cell
				guard let unreadCount = sessionValues["unread_count"] as? Int else { return }
				for (idx, session) in self._sessions.enumerated(){
					if (session.id == snapshot.key){
						if(self.displayMode == .sessions){
							session.unreadCount = unreadCount
							let idxPath = IndexPath(row: idx + 1, section: 0)
							self.tableNode.reloadRows(at: [idxPath], with: .fade)
						}
						return
					}
				}
			}
			
			// removes from screen
			for (idx, session) in self._sessions.enumerated(){
				if (session.id == snapshot.key){
					self._sessions.remove(at: idx)
					if(self.displayMode == .sessions){
						let idxPath = IndexPath(row: idx + 1, section: 0)
						self.tableNode.deleteRows(at: [idxPath], with: .fade)
					}
					return
				}
			}
		}
	}

	private func selectDisplayMode(){
		if (_sessions.count == 0 && _requests.count == 0){
			// show empty message
		} else if (_sessions.count == 0){
			// show requests
			displayMode = .requests
		} else if (_requests.count == 0){
			// show friends
			displayMode = .sessions
		}
	}

	private func observeLastMessage(of sessionId: String){
		// queries to last message
		let messageQuery = FirebaseService.sessionsReference.child(sessionId).child("messages").queryLimited(toLast: 1)
		messageQuery.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
			if let message = snapshot.value as? NSDictionary{
				let messageString = message["text"] as! String
				for (idx, session) in self._sessions.enumerated(){
					if (session.id == sessionId){
						session.lastMessage = messageString
						// should "bubble" cell to first position of table
						self._sessions = self.rearrange(array: self._sessions, fromIndex: idx, toIndex: 0)
						// reloads rows that have been swapped
						self.tableNode.reloadRows(at: [IndexPath(item: 1, section: 0), IndexPath(item: idx + 1, section: 0)], with: .fade)
						return
					}
				}
			}
		}
	}
	
	func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
		var arr = array
		let element = arr.remove(at: fromIndex)
		arr.insert(element, at: toIndex)
		return arr
	}
	
	
}
