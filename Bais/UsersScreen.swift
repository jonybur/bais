//
//  ContainerScreen.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 18/7/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import SwiftyJSON
import AwaitKit
import UIKit
import AsyncDisplayKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import pop
import DGActivityIndicatorView
import ESTabBarController

class UsersScreen : ASViewController<ASScrollNode>, UserCardDelegate{
	
	var animating : Bool = false;
	var scrollNode : ASScrollNode = ASScrollNode();
	var yPosition : CGFloat = GradientBar.height + 10;
	
	init() {
		super.init(node: ASScrollNode());
	}
	
	required init(coder: NSCoder){
		super.init(node: ASScrollNode());
	}
	
	let activityIndicatorView = DGActivityIndicatorView(type: .ballScale,
	                                                    tintColor: ColorPalette.baisOrange,
	                                                    size: 75);
	
	override func viewDidLoad() {
		
		super.viewDidLoad();
		
		automaticallyAdjustsScrollViewInsets = false;
		
		view.backgroundColor = ColorPalette.baisBeige;
		
		activityIndicatorView!.frame = CGRect(x: (ez.screenWidth - 75) / 2,
		                                      y: (ez.screenHeight - 75) / 2,
		                                      width: 75, height: 75);
		
		self.view.addSubview(activityIndicatorView!);
		
		activityIndicatorView?.startAnimating();
		
		self.scrollNode.frame = CGRect(x:0, y:0, width: ez.screenWidth, height: ez.screenHeight);
		self.scrollNode.view.contentSize = CGSize(width: ez.screenWidth, height: yPosition + 100);
		self.view.addSubview(self.scrollNode.view);
		
		self.scrollNode.view.setContentOffset(CGPoint(x:0, y: 0), animated: false);
		
		observeLocation();
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated);
	}
	
	let usersRef = FIRDatabase.database().reference().child("users");
	
	private func observeLocation(){
		let locationRef = usersRef.child((FIRAuth.auth()?.currentUser?.uid)!).child("location");
		locationRef.observe(.value, with: { (snapshot: FIRDataSnapshot!) in

			if let dict = snapshot.value as? NSDictionary{

				let latitude = dict["lat"] as! Double;
				let longitude = dict["lon"] as! Double;
				
				CurrentUser.location = CLLocation(latitude: latitude, longitude: longitude);
			
				self.observeUsers();
				
				// remove observer
				locationRef.removeAllObservers();
			}
		
		});
	}
	
	private func observeUsers(){
		var column : Bool = true;
		var yLeftColumnPosition : CGFloat = 80;
		var yRightColumnPosition : CGFloat = 80;
		
		usersRef.observe(.childAdded) { (snapshot: FIRDataSnapshot!) in
			
			let user = User(fromSnapshot: snapshot);
			
			if (user.id == (FIRAuth.auth()?.currentUser?.uid)!){
				return;
			}
			
			let userCard = ASUserCard(user, yPosition: self.yPosition, column: column);
			userCard.delegate = self;
			self.scrollNode.addSubnode(userCard);
			
			if (!column){
				yLeftColumnPosition += userCard.frame.height + 10;
				self.yPosition = yRightColumnPosition;
			} else {
				yRightColumnPosition += userCard.frame.height + 10;
				self.yPosition = yLeftColumnPosition;
			}
			
			column = !column;
			
			var yBottom : CGFloat;
			if (yLeftColumnPosition > yRightColumnPosition){
				yBottom = yLeftColumnPosition;
			}else{
				yBottom = yRightColumnPosition;
			}
			
			self.scrollNode.view.contentSize = CGSize(width: ez.screenWidth, height: yBottom + 100);
			
			self.activityIndicatorView?.removeFromSuperview();
		}

	
	}
	
	// ASUserCard delegate methods
	func userCardButtonDidClick(sender: ASUserCard) {
		switch (sender.friendshipStatus){
		
		case .noRelationship:
			FirebaseAPI.sendFriendRequestTo(friendId: sender.cardUser.id);
			break;
		case .invited:
			break;
		case .accepted:
			self.navigationController?.pushViewController(ChatScreen(withUser: sender.cardUser), animated: true);
			break;
		default:break;
			
		}
	}
	
	func userCardDidClick(sender: ASUserCard) {
		// animate card
		if (animating){
			return;
		}
		
		animating = true;
		
		// animates the check
		let spring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY);
		spring?.velocity = NSValue(cgPoint: CGPoint(x: -5, y: -5));
		spring?.springBounciness = 5;
		spring?.completionBlock = {(animation, finished) in
			
			let nextView = ProfileScreen(user: sender.cardUser);
			
			UIView.animate(withDuration: 0.3, animations: { () -> Void in
				UIView.setAnimationCurve(UIViewAnimationCurve.easeInOut)
				
				self.navigationController?.pushViewController(nextView, animated: false);
				let animation = CATransition()
				animation.duration = 0.3
				animation.type = kCATransitionMoveIn
				animation.subtype = kCATransitionFromRight
				animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
				self.navigationController?.view.layer.add(animation, forKey: "")
				
				self.animating = false;
			})
			
		}
		sender.pop_add(spring, forKey: "sendAnimation");


	}
	
}
