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
import AsyncDisplayKit

protocol UserCardDelegate: class {
	func userCardButtonDidClick(sender: BAUserCard);
	
	func userCardDidClick(sender: BAUserCard);

}

class BAUserCard : ASButtonNode{
	
	var cardUser : User!;
	var friendshipStatus : FriendshipStatus = .undefined;
	weak var delegate : UserCardDelegate?;
	
	init (_ user : User, yPosition : CGFloat, column : Bool){
		super.init();
		
		cardUser = user;
		
		let cardWidth : CGFloat = (ez.screenWidth / 2) - 15;
		let randomHeight : CGFloat = (CGFloat)(Int(arc4random_uniform(60) + 1)) + 15;
		let buttonHeight : CGFloat = 40;
		let cardHeight : CGFloat = cardWidth + randomHeight + buttonHeight;
		
		var xPosition : CGFloat = 10;
		
		if (!column){
			xPosition += (ez.screenWidth / 2) - 5;
		}
		
		self.frame = CGRect(x: xPosition, y: yPosition, width: cardWidth, height: cardHeight);
		self.backgroundColor = UIColor.white;
		self.addTarget(self, action: #selector(cardPressed(sender:)), forControlEvents: .touchUpInside);
		
		let photoHeight = cardHeight - buttonHeight;
		
		let imageNode = ASNetworkImageNode();
		imageNode.frame = CGRect(x: 0, y: 0, width: cardWidth, height: photoHeight);
		imageNode.setURL(URL(string: user.profilePicture), resetToDefault: false);
		imageNode.shouldRenderProgressImages = true;
		
		let buttonNode = ASButtonNode();
		buttonNode.frame = CGRect(x: 0, y: cardHeight - buttonHeight, width: cardWidth, height: buttonHeight);
		buttonNode.addTarget(self, action: #selector(buttonPressed(sender:)), forControlEvents: .touchUpInside);
		
		// query to friend relationship
		let relationshipQuery = FIRDatabase.database().reference().child("users")
			.child((FIRAuth.auth()?.currentUser?.uid)!).child("friends").child(cardUser.id);
		relationshipQuery.observe(.value) { (snapshot: FIRDataSnapshot!) in
			
			let buttonString : String!;
			
			if let relationship = snapshot.value as? NSDictionary{
				let status = relationship["status"] as! String;
				self.friendshipStatus = FriendshipStatus(rawValue : status)!;
				
				switch (self.friendshipStatus){
				
				case .accepted:
					buttonString = "Chat";
					break;
				case .invited:
					buttonString = "Request Sent";
					break;
				default:
					buttonString = "";
					break;
					
				}
				
			}
			else {
				buttonString = "Connect";
				self.friendshipStatus = .noRelationship;
			}
			
			buttonNode.setTitleInMiddleAlignment(buttonString, withFont: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium),
			                                     withColor: ColorPalette.baisOrange, state: ASControlState());
		}
		
		let shadow : NSShadow = NSShadow();
		shadow.shadowColor = UIColor.black;
		shadow.shadowBlurRadius = 2;
		shadow.shadowOffset = CGSize(width: 0, height: 0);
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: UIColor.white,
			NSShadowAttributeName: shadow]
		
		let distanceAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight),
			NSForegroundColorAttributeName: UIColor.white,
			NSShadowAttributeName: shadow]
		
		// black gradient
		let gradientView: UIView = UIView(frame: CGRect(x: 0.0, y: imageNode.frame.height * 0.67,
		                                                width: imageNode.frame.width, height: imageNode.frame.height * 0.33));
		let gradient: CAGradientLayer = CAGradientLayer();
		gradient.frame = gradientView.bounds;
		gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor];
		gradientView.layer.insertSublayer(gradient, at: 0);
		gradientView.alpha = 0.5;

		let flagNode = ASImageNode();
		flagNode.image = UIImage(named: "Argentina");
		flagNode.frame = CGRect(x: 10, y: 7, width: 20, height: 20);
		flagNode.contentMode = .scaleAspectFit;
		
		let nameNode = ASTextNode();
		nameNode.frame = CGRect(x: 10, y: photoHeight - 45, width: cardWidth - 15, height: 20);
		nameNode.attributedText = NSAttributedString(string: user.firstName, attributes: nameAttributes);
		
		let distanceNode = UILabel();
		distanceNode.frame = CGRect(x:10, y: nameNode.frame.maxY, width: cardWidth - 15, height: 20);
		
		let distanceString = self.cardUser.location.distance(from: CurrentUser.location!).redacted();
		distanceNode.adjustsFontSizeToFitWidth = true;
		distanceNode.attributedText = NSAttributedString(string: distanceString, attributes: distanceAttributes);
		
		// self.view isn't a node, so we can only use it on the main thread
	
		self.layer.cornerRadius = 10;
		self.view.clipsToBounds = true;
		self.view.addSubnode(imageNode);
		self.view.addSubnode(buttonNode);
		self.view.addSubview(gradientView);
		self.view.addSubnode(nameNode);
		self.view.addSubnode(flagNode);
		self.view.addSubview(distanceNode);
	}
	
	func cardPressed(sender : UIButton){
		delegate?.userCardDidClick(sender: self);
	}
	
	func buttonPressed(sender : UIButton){
		delegate?.userCardButtonDidClick(sender: self)
	}
}
