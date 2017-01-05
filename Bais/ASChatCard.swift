//
//  UIUserCard.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 1/8/16.
//  Copyright Â© 2016 Claxon. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase
import pop
import AsyncDisplayKit

protocol ChatCardDelegate: class {
	func chatCardDidClick(sender: ASChatCard);
}

protocol ChatCardButtonsDelegate:class {
	func acceptButtonPress(sender: ASImageNode);
	func cancelButtonPress(sender: ASImageNode);
}

class ASChatCardButtons : ASDisplayNode{

	weak var delegate : ChatCardButtonsDelegate?;
	
	override init(){
		super.init();
		
		let buttonSize : CGFloat = 44;
		
		self.frame = CGRect(0, 0, buttonSize * 2 + 20, buttonSize);
		
		let acceptButtonNode = ASImageNode();
		acceptButtonNode.image = UIImage(named: "accept-button");
		acceptButtonNode.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize);
		acceptButtonNode.position = CGPoint(buttonSize / 2, self.frame.height / 2);
		acceptButtonNode.addTarget(self, action: #selector(acceptButtonPress(sender:)), forControlEvents: .touchUpInside);
		
		let cancelButtonNode = ASImageNode();
		cancelButtonNode.image = UIImage(named: "cancel-button");
		cancelButtonNode.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize);
		cancelButtonNode.position = CGPoint(acceptButtonNode.frame.maxX + buttonSize/2 + 20, self.frame.height / 2);
		cancelButtonNode.addTarget(self, action: #selector(cancelButtonPress(sender:)), forControlEvents: .touchUpInside);
		
		self.addSubnode(acceptButtonNode);
		self.addSubnode(cancelButtonNode);
	}
	
	func acceptButtonPress(sender: ASImageNode){
		delegate?.acceptButtonPress(sender: sender);
		bounceAnimation(sender.view);
	}
	
	func cancelButtonPress(sender:ASImageNode){
		delegate?.cancelButtonPress(sender: sender);
		bounceAnimation(sender.view);
	}
	
	internal func bounceAnimation(_ view: UIView) {
		let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
		impliesAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
		impliesAnimation.duration = 0.5
		impliesAnimation.calculationMode = kCAAnimationCubic
		
		view.layer.add(impliesAnimation, forKey: nil)
	}

	
}

class ASChatCard : ASButtonNode, ChatCardButtonsDelegate{
	
	var cardUser : User!;
	
	let height : CGFloat = 75;
	let lastMessageNode = ASTextNode();
	var chatCardButtons : ASChatCardButtons?;
	var chatIsEnabled : Bool = false;

	weak var delegate : ChatCardDelegate?;
	
	init (_ user : User){
		super.init();
		
		cardUser = user;
		
		self.frame = CGRect(x: 0, y: 0, width: ez.screenWidth, height: self.height);
		self.addTarget(self, action: #selector(buttonPressed(sender:)), forControlEvents: .touchUpInside);
		self.backgroundColor = UIColor.white;
		
		let photoHeight = 55;
		
		let imageNode = ASNetworkImageNode();
		imageNode.frame = CGRect(x: 10, y: 10, width: photoHeight, height: photoHeight);
		imageNode.setURL(URL(string: user.profilePicture), resetToDefault: false);
		imageNode.shouldRenderProgressImages = true;
		
		let imageCornersNode = ASImageNode();
		imageCornersNode.frame = imageNode.frame;
		imageCornersNode.image = UIImage(named: "image-corners");
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: UIColor.black]
		
		let nameNode = ASTextNode();
		nameNode.frame = CGRect(x: imageNode.frame.maxX + 10, y: 20, width: 200, height: 20);
		nameNode.attributedText = NSAttributedString(string: user.fullNameConfidential(), attributes: nameAttributes);
		
		lastMessageNode.frame = CGRect(x: imageNode.frame.maxX + 10, y: nameNode.frame.maxY + 3, width: 200, height: 20);
		
		observeLastMessage();
		observeFriendshipStatus();
		
		// self.view isn't a node, so we can only use it on the main thread
		self.view.clipsToBounds = true;
		self.view.addSubnode(imageNode);
		self.view.addSubnode(imageCornersNode);
		self.view.addSubnode(nameNode);
		self.view.addSubnode(lastMessageNode);
	}
	
	func observeLastMessage(){
		let distanceAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight),
			NSForegroundColorAttributeName: UIColor.black]
		
		// query to last message
		let messageQuery = FIRDatabase.database().reference().child("messages")
			.child((FIRAuth.auth()?.currentUser?.uid)!).child(cardUser.id).queryLimited(toLast: 1);
		
		messageQuery.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
			
			if let message = snapshot.value as? NSDictionary{
				let messageString = message["text"] as! String;
				self.lastMessageNode.attributedText = NSAttributedString(string: messageString, attributes: distanceAttributes)
			}
			
		}
	}
	
	func observeFriendshipStatus(){
		// query to friendship status
		let thisUserId = (FIRAuth.auth()?.currentUser?.uid)!;
		let userFriendsRef = FIRDatabase.database().reference().child("users")
			.child(thisUserId).child("friends").child(cardUser.id);
		
		userFriendsRef.observe(.value, with: { (snapshot: FIRDataSnapshot!) in
			
			if let friendshipInformation = snapshot.value as? NSDictionary{
				
				let postedBy = friendshipInformation["postedBy"] as! String;
				let friendshipStatusValue = friendshipInformation["status"] as! String;
				let friendshipStatus = FriendshipStatus(rawValue: friendshipStatusValue);
				
				if (friendshipStatus == .accepted){
					self.chatIsEnabled = true;
				}
				
				if (postedBy != thisUserId){
					
					switch (friendshipStatus!){
					
					case .invited:
						self.chatCardButtons = ASChatCardButtons();
						self.chatCardButtons?.position = CGPoint(self.frame.width - (self.chatCardButtons?.frame.width)! / 2 - 10, self.frame.height / 2);
						self.chatCardButtons?.delegate = self;
						self.view.addSubnode(self.chatCardButtons!);
						self.chatIsEnabled = false;
						break;
						
					case .accepted:
						// TODO: hacer que la lista (el viewcontroller) se ordene - pasar el metodo que remueve al view a un delegado y llamarlo desde el FriendsScreen.
						self.chatCardButtons?.removeFromSupernode();
						self.chatCardButtons = nil;
						break;
					
					default:
						break;
						
					}

				}
				
			} else {
			
				self.chatCardButtons?.removeFromSupernode();
				self.chatCardButtons = nil;
				// remove the ASChatCard from superview
				self.removeFromSupernode();
			
			}
			
		});
	}
	
	func buttonPressed(sender : UIButton){
		if (chatIsEnabled){
			delegate?.chatCardDidClick(sender: self)
		}
	}
	
	// ChatCardButtonsDelegate Methods
	internal func acceptButtonPress(sender: ASImageNode) {
		FirebaseAPI.acceptFriendRequestFrom(friendId: cardUser.id);
	}

	internal func cancelButtonPress(sender: ASImageNode) {
		FirebaseAPI.denyFriendRequestFrom(friendId: cardUser.id);
	}
	
}
