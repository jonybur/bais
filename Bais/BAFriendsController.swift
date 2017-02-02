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

final class BAFriendsController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, BAChatHeaderCellNodeDelegate {
	
	var _sections = [User]()
	var _friends = [User]()
	var _requests = [User]()
	var showRequests: Bool = false
	
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
		
		if (indexPath.item == 0){
			return
		}
		
		let user = _sections[indexPath.item - 1]
		self.navigationController?.pushViewController(BAChatController(with: user), animated: true)
		self.tableNode.deselectRow(at: indexPath, animated: true)
	}
	
	//MARK: - ASTableNode data source and delegate.
	
	func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		let item = indexPath.item
		
		if (item == 0){
			let headerNode = BAChatHeaderCellNode()
			headerNode.delegate = self
			return headerNode
		}
		
		let user = _sections[item - 1]
		
		
		if (showRequests){
			let chatNode = BAFriendRequestCellNode(with: user)
			return chatNode
		}
		
		let chatNode = BAChatCellNode(with: user)
		return chatNode
	}
	
	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return self._sections.count > 0 ? self._sections.count + 1 : 0;
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if (indexPath.item == 0 || showRequests){
			return false
		}
		return true
	}
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let removeAction = UITableViewRowAction(style: .normal, title: "Reject") { (rowAction, indexPath) in }
		removeAction.backgroundColor = ColorPalette.baisOrange
		return [removeAction]
	}
	
	//MARK: - BAChatHeaderCellNodeDelegate
	func chatHeaderCellNodeDidClickButton(_ chatViewCell: BAChatHeaderCellNode) {
		
		if (showRequests){
			_sections = _friends
		} else {
			_sections = _requests
		}
		
		let tableRows = tableNode.numberOfRows(inSection: 0) - 1
		if (tableRows < _sections.count){
			var idxToInsert = [IndexPath]()
			for idx in tableRows..._sections.count-1{
				let idxPath = IndexPath(item:idx, section:0)
				idxToInsert.append(idxPath)
			}
			tableNode.insertRows(at: idxToInsert, with: .fade)
		} else {
			var idxToRemove = [IndexPath]()
			for idx in _sections.count+1...tableRows{
				let idxPath = IndexPath(item:idx, section:0)
				idxToRemove.append(idxPath)
			}
			tableNode.deleteRows(at: idxToRemove, with: .fade)
		}
		
		var idxToReload = [IndexPath]()
		for idx in 1..._sections.count{
			let idxPath = IndexPath(row: idx, section: 0)
			idxToReload.append(idxPath)
		}
		
		showRequests = !showRequests
		tableNode.reloadRows(at: idxToReload, with: .fade)
	
	}
	
	//MARK: - Firebase
	
	// gets friends and reloads table after getting all information
	private func observeFriends() {
		let userId = (FIRAuth.auth()?.currentUser?.uid)!
		let userFriendsRef = FirebaseService.usersReference.child(userId).child("friends")
				
		// grabs all my friends
		// TODO: should suscribe to a childAdded
		userFriendsRef.observe(.value, with: { (snapshot: FIRDataSnapshot!) in
			if let relationshipsDictionary = snapshot.value as? NSDictionary {
				var promises = [Promise<Void>]()
				// for each user
				for relationship in relationshipsDictionary{
					let friendId = String(describing: relationship.key)
					let relationshipAttributes = relationship.value as! NSDictionary
					let statusString = relationshipAttributes["status"] as! String
					let status = FriendshipStatus(rawValue: statusString)!
					if (status == .accepted || status == .invited) {
						// if it's a friend, or was invited by someone, create the chat card
						let promise = self.getUser(with: friendId).then(execute: { user -> Void in
							// get user
							user.friendshipStatus = status
							if (status == .accepted){
								self._friends.append(user)
							} else if (status == .invited){
								self._requests.append(user)
							}
						})
						promises.append(promise)
					}
				}
				
				when(resolved: promises).then(execute: { _ -> Void in
					self._sections = self._friends
					self.tableNode.reloadData()
				})
			}
		});
	}
	
	private func getUser(with id: String) -> Promise<User>{
		return Promise{ fulfill, reject in
			let userQuery = FirebaseService.usersReference.child(id)
			userQuery.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot!) in
				if let userDictionary = snapshot.value as? NSDictionary{
					let user = User(fromNSDictionary: userDictionary)
					fulfill(user)
				}
			}
		}
	}
}
