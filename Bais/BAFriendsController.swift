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
	
	// change this to one user array _usersToDisplay with two pointer arrays sessions and requests
	// also, change this to dictionaries String:User
    var sessions = [Session]()
    var sessionsWithMessages = [Session]()
	var requests = [User]()
	var emptyStateMessagesNode = BAEmptyStateMessagesCellNode()
	var emptyStateFriendRequestNode = BAEmptyStateFriendRequestsCellNode()
	var displayMode: ChatDisplayMode = .sessions
	
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
		node.addSubnode(emptyStateMessagesNode)
		node.addSubnode(emptyStateFriendRequestNode)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
//MARK: - ASTableNode didSelectRowAt
	
	func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
		if (indexPath.item == 0){
			return
		}
        
        if (sessionListWithNoMessages().count > 0 && (indexPath.item == 1 || indexPath.item == 3)){
            return
        }
		
		if (displayMode == .requests){
			// taps request
			let user = requests[indexPath.item - 1]
			self.navigationController?.pushViewController(BAProfileController(with: user), animated: true)
			self.tableNode.deselectRow(at: indexPath, animated: true)
			return
		}
        
        if (indexPath.item == 1 && sessionListWithNoMessages().count > 0){
            return
        }
		
        // ignore last item in table (last item is a spacer)
        if (indexPath.item == tableNode.numberOfRows(inSection: 0) - 1){
            return
        }
        
		// taps friend (opens chat)
        // TODO: improve this method
        let sessionsToLoad = sessionListWithMessages()
        var rowsDelta = tableNode.numberOfRows(inSection: 0) - sessionsToLoad.count - 1
        if (sessionListWithNoMessages().count == 0){
            rowsDelta += 1
        }
        
		let session = sessionsToLoad[indexPath.item - rowsDelta]
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
			let user = requests[item - 1]
			let chatNode = BAFriendRequestCellNode(with: user)
			chatNode.delegate = self
			return chatNode
		}
		
        if (sessionListWithNoMessages().count > 0) {
            // should load horizontal chat list
            // gets list of sessions that has no messages
            
            if (item == 1){
                return BAChatHorizontalHeaderCellNode()
            } else if (item == 2){
                let node = ASCellNode(viewControllerBlock: { () -> UIViewController in
                    let sessionsWithNoMessages = self.sessionListWithNoMessages()
                    let chatHorizontalController = BAChatHorizonalController(with: sessionsWithNoMessages)
                    chatHorizontalController.superNavigationController = self.navigationController
                    chatHorizontalController.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: ez.screenWidth, height: 130))
                    return chatHorizontalController
                }, didLoad: nil)
                node.style.preferredSize = CGSize(width: ez.screenWidth, height: 130)
                
                return node;
            } else if (item == 3 && self.sessionsWithMessages.count > 0){
                return BAChatVerticalHeaderCellNode()
            }
        }
        
        let sessionsToLoad = sessionsWithMessages
        // TODO: make this work with other variable of headers (4 is current)
        let idx = sessionListWithNoMessages().count > 0 ? item - 4 : item - 1
        if (sessionsToLoad.count > idx && idx >= 0){
            let session = sessionsToLoad[idx]
            let chatNode = BAChatCellNode(with: session)
            return chatNode
        }
        
		return BASpacerCellNode()
	}
	
	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
    
    func rowCountForSessionsAndNoMessages() -> Int{
        return sessionsWithMessages.count + 2 + 1 /*header for new friends*/ + 1 /*header for messages*/ + 1 /*spacer*/
    }
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		var rowCount = 0
		
		// gets item count (includes header)
		if (displayMode == .requests){
			rowCount = requests.count > 0 ? requests.count + 1 : 1
		} else if (displayMode == .sessions){
            if (sessions.count == 0){
                return 1;
            }
			
            if (sessionListWithNoMessages().count > 0){
                // adds horizontal scrolling list (this means +1 rowCount for all of the messages)
                rowCount = rowCountForSessionsAndNoMessages()
            } else {
                rowCount = sessionsWithMessages.count + 1
            }
		}
		
		displayEmptyState(rowCount)
		
		// return normal count
		return rowCount
	}
    
    func sessionListWithMessages() -> [Session]{
        let messagesSessions = self.sessions.filter ({ session -> Bool in
            return session.lastMessage.timestamp != 0
        })
        return messagesSessions.sorted(by: { $0.lastMessage.timestamp > $1.lastMessage.timestamp })
    }
    
    func sessionListWithNoMessages() -> [Session]{
        return [Session]()/*self.sessions.filter ({ session -> Bool in
            return session.lastMessage.timestamp == 0
        })*/
        
        // should sort by creation date
        //return sessions.sorted(by: { $0.lastMessage.timestamp > $1.lastMessage.timestamp })
    }
	
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if (indexPath.item == 0 || displayMode == .sessions){
			return false
		}
		return true
	}
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let removeAction = UITableViewRowAction(style: .normal, title: "Reject") { (rowAction, indexPath) in
			FirebaseService.denyFriendRequestFrom(friendId: self.requests[indexPath.item - 1].id)
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
			elementsToDisplay = requests.count + 1
		} else if (displayMode == .sessions){
            if (sessions.count == 0){
                elementsToDisplay = 1;
            } else {
                if (sessionListWithNoMessages().count > 0){
                    // adds horizontal scrolling list (this means +1 rowCount for all of the messages)
                    elementsToDisplay = rowCountForSessionsAndNoMessages()
                } else {
                    // no horizontal scrolling list
                    elementsToDisplay = sessions.count + 1
                }
            }
        }
		
		// current row count
		let tableRows = tableNode.numberOfRows(inSection: 0)
		if (tableRows < elementsToDisplay){
			// need to add more rows to make up for elementsToDisplay
			var idxToInsert = [IndexPath]()
			for idx in tableRows...elementsToDisplay - 1{
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
		displayEmptyState(tableNode.numberOfRows(inSection: 0))
	}
	
	private func displayEmptyState(_ rowCount: Int){
		// if only got header back, then should show empty state cell node
		if (rowCount == 1){
			if (displayMode == .requests){
				emptyStateMessagesNode.alpha = 0
				emptyStateFriendRequestNode.alpha = 1
			} else if (displayMode == .sessions){
				emptyStateMessagesNode.alpha = 1
				emptyStateFriendRequestNode.alpha = 0
			}
		} else {
			emptyStateMessagesNode.alpha = 0
			emptyStateFriendRequestNode.alpha = 0
		}
	}
	
//MARK: - Firebase
	
	// gets friends and reloads table after getting all information
	private func observeFriends() {
		
		// user friends (REQUESTS)
		let userId = FirebaseService.currentUserId
		let userFriendsRef = FirebaseService.usersReference.child(userId).child("friends")
		
		userFriendsRef.observe(.childChanged) { (snapshot: FIRDataSnapshot!) in
			let userId = snapshot.key
			let status = FirebaseService.parseFriendStatus(from: snapshot)
			
			// if status is accepted, remove from requests
			if (status == .accepted){
				for (idx, user) in self.requests.enumerated(){
					if (user.id == userId){
						self.requests.remove(at: idx)
						if (self.displayMode == .requests){
							let idxPath = IndexPath(row: idx + 1, section: 0)
							self.tableNode.deleteRows(at: [idxPath], with: .fade)
						}
						return
					}
				}
			}
			let tableRows = self.tableNode.numberOfRows(inSection: 0)
			self.displayEmptyState(tableRows)
			
		}
		userFriendsRef.observe(.childRemoved) { (snapshot: FIRDataSnapshot!) in
			for (idx, request) in self.requests.enumerated(){
				if (request.id == snapshot.key){
					self.requests.remove(at: idx)
					if(self.displayMode == .requests){
						let idxPath = IndexPath(row: idx + 1, section: 0)
						self.tableNode.deleteRows(at: [idxPath], with: .fade)
					}
					return
				}
			}
            let tableRows = self.tableNode.numberOfRows(inSection: 0)
            self.displayEmptyState(tableRows)
		}
		userFriendsRef.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
			// promises get resolved when all users are complete
			FirebaseService.getUserFromRelationship(from: snapshot).then(execute: { user -> Void in
				// got user
				if (user.friendshipStatus == .invitationReceived){
					self.requests.append(user)
					if (self.displayMode == .requests){
						// add new row to section
						let idxPath = IndexPath(row: self.requests.count, section: 0)
						self.tableNode.insertRows(at: [idxPath], with: .fade)
					}
				}
			}).catch(execute: { _ in })
		}
		
		// user sessions (CHATS)
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
                self.sessions.append(session)
				self.observeLastMessage(of: session)
			}).catch(execute: { _ in })
		}
	
		userSessionsRef.observe(.childChanged) { (snapshot: FIRDataSnapshot!) in
			
			// checks if session activity was turned to false
			guard let sessionValues = snapshot.value as? NSDictionary else { return }
			guard let sessionIsActive = sessionValues["active"] as? Bool else { return }
			if (sessionIsActive){
				// should update the cell
				guard let unreadCount = sessionValues["unread_count"] as? Int else { return }
				for (idx, session) in self.sessions.enumerated(){
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
			for (idx, session) in self.sessions.enumerated(){
				if (session.id == snapshot.key){
					self.sessions.remove(at: idx)
					if(self.displayMode == .sessions){
						let idxPath = IndexPath(row: idx + 1, section: 0)
						self.tableNode.deleteRows(at: [idxPath], with: .fade)
					}
					return
				}
			}
			
			let tableRows = self.tableNode.numberOfRows(inSection: 0)
			self.displayEmptyState(tableRows)
		}
	}

	private func selectDisplayMode(){
		if (sessions.count == 0 && requests.count == 0){
			// show empty message
		} else if (sessions.count == 0){
			// show requests
			displayMode = .requests
		} else if (requests.count == 0){
			// show friends
			displayMode = .sessions
		}
	}
    
    func reloadActiveRows(){
        if (sessionListWithNoMessages().count > 0){
            // adds horizontal scrolling list (this means +1 rowCount for all of the messages)
            // refreshes rows
            
            var idxPaths = [IndexPath]()
            for idx in 3...self.tableNode.numberOfRows(inSection: 0) - 1{
                idxPaths.append(IndexPath(item: idx, section: 0))
            }
            self.tableNode.reloadRows(at: idxPaths, with: .fade)
            
        } else {
            //rowCount = sessionsWithMessages.count + 1
        }
    }

	private func observeLastMessage(of session: Session){
		// queries to last message
		let messageQuery = FirebaseService.sessionsReference.child(session.id).child("messages").queryLimited(toLast: 1)
        
		messageQuery.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
            
			if let messageDictionary = snapshot.value as? NSDictionary{
				
				let text = messageDictionary["text"] as! String
				let senderId = messageDictionary["sender_id"] as! String
				let message = Message(text: text, senderId: senderId)
				message.timestamp = messageDictionary["timestamp"] as! CGFloat
                
                // if session didnt have messages (or first time retrieving)
                if (!self.sessionsWithMessages.contains(where: { s -> Bool in session.id == s.id})){
                    self.sessionsWithMessages.append(session)
                }
                
                // TODO: no need for this when sessions become a dictionary
                for (idx, s) in self.sessions.enumerated() {
                    if (s.id == session.id){
                        s.lastMessage = message;
                        self.sessions[idx] = s;
                    }
                }
                
                // sort to have ordered timestamps
                self.sessionsWithMessages = self.sessionsWithMessages.sorted(by: { $0.lastMessage.timestamp > $1.lastMessage.timestamp })
                
                let _ = self.tableNode.numberOfRows(inSection: 0)
                self.tableNode.reloadData()
                
                self.reloadActiveRows()
			}
		}
	}
	
}
