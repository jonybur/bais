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

final class BAFriendsController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate {
	
	let usersRef = FIRDatabase.database().reference().child("users");
	var _sections = [User]()
	
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
	
	//MARK: - ASTableNode didSelectRowAt.
	
	func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
		let user = _sections[indexPath.item - 1]
		self.navigationController?.pushViewController(BAChatController(with: user), animated: true)
		self.tableNode.deselectRow(at: indexPath, animated: true)
	}
	
	//MARK: - ASTableNode data source and delegate.
	
	func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		// Should read the row count directly from table view but
		// https://github.com/facebook/AsyncDisplayKit/issues/1159
		
		let item = indexPath.item
		
		if (item == 0){
			let headerNode = BAChatHeaderCellNode(with: _sections[0])
			return headerNode
		}
		
		let user = _sections[item - 1]
		let chatNode = BAChatCellNode(with: user)
		return chatNode
	}
	
	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return self._sections.count > 0 ? self._sections.count + 1 : 0;
	}
	
	//MARK: - Firebase
	
	// gets friends and reloads table after getting all information
	private func observeFriends() {
		let userId = (FIRAuth.auth()?.currentUser?.uid)!
		let userFriendsRef = FIRDatabase.database().reference().child("users").child(userId).child("friends")
				
		// grabs all my friends
		userFriendsRef.observe(.value, with: { (snapshot: FIRDataSnapshot!) in
			if let relationshipsDictionary = snapshot.value as? NSDictionary {
				
				var promises = [Promise<Void>]()
				
				// for each user
				for relationship in relationshipsDictionary{
					
					let friendId = String(describing: relationship.key)
					let relationshipAttributes = relationship.value as! NSDictionary
					let statusString = relationshipAttributes["status"] as! String
					let status = FriendshipStatus(rawValue: statusString)!
					
					if (status == .accepted) {
						
						// if it's a friend, or was invited by someone, create the chat card
						let promise = self.getUser(with: friendId).then(execute: { user -> Void in
							// get user
							user.friendshipStatus = .accepted
							self._sections.append(user)
						})
						
						promises.append(promise)
					}
				}
				
				when(resolved: promises).then(execute: { _ -> Void in
					self.tableNode.reloadData()
				})
				
			}
		});
	}
	
	private func getUser(with id: String) -> Promise<User>{
		return Promise{ fulfill, reject in
			let userQuery = FIRDatabase.database().reference().child("users").child(id)
			userQuery.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot!) in
				if let userDictionary = snapshot.value as? NSDictionary{
					let user = User(fromNSDictionary: userDictionary)
					fulfill(user)
				}
			}
		}
	}
}
