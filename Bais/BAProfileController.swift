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

final class BAProfileController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, UIGestureRecognizerDelegate, BABasicUserInfoCellNodeDelegate {
	
	// change this to one user array _usersToDisplay with two pointer arrays _friends and _requests
	var user = User()
	var backButtonNode = ASButtonNode()
	var actionButtonNode: BAFriendshipActionButtonNode!
	var allowsAction = true
	
	var tableNode: ASTableNode {
		return node as! ASTableNode
	}
	
	init(with userId: String){
		super.init(node: ASTableNode())
		
		FirebaseService.getUser(with: userId).then { user -> Void in
			self.user = user
			self.commonInit()
		}.catch { _ in }
	}
	
	init(with user: User) {
		super.init(node: ASTableNode())
		self.user = user
		commonInit()
	}
	
	func commonInit(){
		tableNode.delegate = self
		tableNode.dataSource = self
		tableNode.view.separatorStyle = .none
		tableNode.allowsSelection = false
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("Storyboards are not supported")
	}
	
	func hideActionButton(){
		actionButtonNode.removeFromSupernode()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		actionButtonNode = BAFriendshipActionButtonNode(with: user.friendshipStatus)
		
		backButtonNode.frame = CGRect(x: 0, y: 10, width: 75, height: 75)
		backButtonNode.setImage(UIImage(named: "back-button"), for: [])
		backButtonNode.addTarget(self, action: #selector(backButtonPressed(_:)), forControlEvents: .touchUpInside)
		actionButtonNode.addTarget(self, action: #selector(actionButtonPressed(_:)), forControlEvents: .touchUpInside)

		super.node.addSubnode(backButtonNode)
		super.node.addSubnode(actionButtonNode)
		
		observeFriendship()
	}
	
	func backButtonPressed(_ sender: UIButton){
		_ = navigationController?.popViewController(animated: true)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		navigationController!.interactivePopGestureRecognizer!.isEnabled = true
		navigationController!.interactivePopGestureRecognizer!.delegate =  self
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if (scrollView.contentOffset.y < 0){
			scrollView.contentOffset.y = 0
		}
		
		backButtonNode.view.center = CGPoint(x: backButtonNode.view.center.x,
		                                     y: scrollView.contentOffset.y + backButtonNode.view.frame.height / 2 + 10)
		
		actionButtonNode.view.center = CGPoint(x: actionButtonNode.view.center.x,
		                                       y: scrollView.contentOffset.y + ez.screenHeight - actionButtonNode.view.frame.height + 15)
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
//MARK: - ASTableNode data source and delegate.
	
	func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		let item = indexPath.item
		
		if (item == 0){
			let headerCellNode = BAImageCarouselCellNode(with: user)
			return headerCellNode
		} else if (item == 1){
			let basicCellNode = BABasicUserInfoCellNode(with: user)
			basicCellNode.delegate = self
			return basicCellNode
		} else if (item == 2){
			let descriptionCellNode = BADescriptionInfoCellNode(with: user)
			return descriptionCellNode
		}
		
		return BASpacerCellNode()
	}
	
	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	
//MARK: - ActionButton delegate
	
	func observeFriendship(){
	
		let userId = FirebaseService.currentUserId
		let userFriendsRef = FirebaseService.usersReference.child(userId).child("friends")
		
		userFriendsRef.observe(.childChanged, with: { snapshot in
			let newFriendshipStatus = FirebaseService.parseFriendStatus(from: snapshot)
			self.refreshButtonFor(userId: snapshot.key, friendshipStatus: newFriendshipStatus)
		})
		
		userFriendsRef.observe(.childAdded, with: { snapshot in
			let newFriendshipStatus = FirebaseService.parseFriendStatus(from: snapshot)
			self.refreshButtonFor(userId: snapshot.key, friendshipStatus: newFriendshipStatus)
		})
		
		userFriendsRef.observe(.childRemoved, with: { snapshot in
			self.refreshButtonFor(userId: snapshot.key, friendshipStatus: .noRelationship)
		})
	}
	
	func refreshButtonFor(userId: String, friendshipStatus: FriendshipStatus){
		if (user.id != userId){
			return
		}
		actionButtonNode.friendshipStatus = friendshipStatus
		actionButtonNode.setFriendshipAction()

	}
	
	func actionButtonPressed(_ button: BAFriendshipActionButtonNode){
		switch (button.friendshipStatus){
		case .noRelationship:
			FirebaseService.sendFriendRequestTo(friendId: user.id)
			button.friendshipStatus = .invitationSent
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
	
//MARK: - BasicUserInfo delegate
	
	func basicUserInfoTapMore(_ basicUserInfoCellNode: BABasicUserInfoCellNode) {
		
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		alert.addAction(UIAlertAction(title: "Report " + user.firstName, style: .default, handler: { action in
			self.reportAction()
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		present(alert, animated: true, completion: nil)
	}
	
	func reportAction(){
		let alert = UIAlertController(title: "Report User", message: "Is this person bothering you?\nTell us what they did.", preferredStyle: .alert)
		alert.addTextField { textField in
			textField.placeholder = "Additional Info (Optional)"
			textField.autocapitalizationType = .sentences
		}
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { action in
			let textField = alert.textFields![0] as UITextField
			FirebaseService.sendReport(for: self.user, reason: textField.text!)
		}))
		present(alert, animated:true, completion:nil)
	}
	
}
