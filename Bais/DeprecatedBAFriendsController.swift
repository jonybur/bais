//
//  LoginScreen.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 18/7/16.
//  Copyright © 2016 Claxon. All rights reserved.
//


import UIKit
import AsyncDisplayKit
import Firebase
import FirebaseDatabase
import CoreGraphics

class DeprecatedBAFriendsController: UIViewController, ChatCardDelegate {
	
	var scrollNode : ASScrollNode = ASScrollNode();
	var yPosition : CGFloat = GradientBar.height;
	let usersRef = FIRDatabase.database().reference().child("users");
	var chatCards = [String: BAChatCard]();
	
	override func viewDidLoad() {
		super.viewDidLoad();
		
		view.backgroundColor = ColorPalette.baisBeige;
		self.automaticallyAdjustsScrollViewInsets = false;
		
		navigationController?.isNavigationBarHidden = true;
		
		self.scrollNode.frame = CGRect(x:0, y:0, width: ez.screenWidth, height: ez.screenHeight);
		self.view.addSubview(self.scrollNode.view);
		
		observeFriends();
	}
	
	private func observeFriends() {
		let userId = (FIRAuth.auth()?.currentUser?.uid)!;
		let userFriendsRef = FIRDatabase.database().reference().child("users").child(userId).child("friends");
		
		var currentCards = [String]();
		
		// grabs all my friends
		userFriendsRef.observe(.value, with: { (snapshot: FIRDataSnapshot!) in
			
			if let relationshipsDictionary = snapshot.value as? NSDictionary{
				
				// for each user
				for relationship in relationshipsDictionary{
					
					let friendId = String(describing: relationship.key);
					if (currentCards.contains(friendId)){
						continue;
					}
					
					let relationshipAttributes = relationship.value as! NSDictionary;
					
					let statusString = relationshipAttributes["status"] as! String;
					let status = FriendshipStatus(rawValue : statusString)!;
					let postedBy = relationshipAttributes["postedBy"] as! String;
					
					if (status == .accepted || (status == .invited && postedBy != userId)) {
						
						// if it's a friend, or was invited by someone, create the chat card
						self.makeChatCard(fromFriendId: friendId);
						currentCards.append(friendId);
						
					}
				
				}
				
				// TODO: fix this
				self.scrollNode.view.contentSize = CGSize(width: ez.screenWidth, height: ez.screenHeight);
			}
			
		});		
	}
	
	func makeChatCard (fromFriendId : String){
		
		let friendRef = FIRDatabase.database().reference().child("users").child(fromFriendId);
		friendRef.observeSingleEvent(of: .value, with: { (singleSnapshot: FIRDataSnapshot!) in
			
			let user = User(fromSnapshot: singleSnapshot);
			let chatCard = BAChatCard(user);
			chatCard.position = CGPoint(ez.screenWidth / 2, self.yPosition + chatCard.frame.height / 2);
			self.yPosition += chatCard.frame.height + 1;
			chatCard.delegate = self;
			self.view.addSubnode(chatCard);
			
			self.chatCards[user.id] = chatCard;
			
		});
	}
	
	// ASChatCard delegate methods
	func chatCardDidClick(sender: BAChatCard) {
	
		let userToChat = sender.cardUser;
		self.navigationController?.pushViewController(BAChatController(with: userToChat!), animated: true);
		
	}

	
}
