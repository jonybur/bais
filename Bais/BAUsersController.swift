//
//  BATabBarController.swift
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

class BAUsersController : ASViewController<ASScrollNode>, UserCardDelegate{
	
	var animating : Bool = false
	var scrollNode : ASScrollNode = ASScrollNode()
	var yPosition : CGFloat = GradientBar.height + 10
	let usersRef = FIRDatabase.database().reference().child("users")
	let activityIndicatorView = DGActivityIndicatorView(type: .ballScale,
	                                                    tintColor: ColorPalette.baisOrange,
	                                                    size: 75)
	
	init() {
		super.init(node: ASScrollNode());
	}
	
	required init(coder: NSCoder){
		super.init(node: ASScrollNode());
	}
	
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
	
	private func observeLocation(){
		let locationRef = usersRef.child((FIRAuth.auth()?.currentUser?.uid)!).child("location");
		locationRef.observe(.value, with: { (snapshot: FIRDataSnapshot!) in

			if let dict = snapshot.value as? NSDictionary{

				let latitude = dict["lat"] as! Double;
				let longitude = dict["lon"] as! Double;
				
				CurrentUser.location = CLLocation(latitude: latitude, longitude: longitude);
			
				//self.observeUsers();
				
				// remove observer
				locationRef.removeAllObservers();
			}
		
		});
	}
	
	//MARK: - ASUserCard delegate methods
	func userCardButtonDidClick(sender: BAUserCard) {
		switch (sender.friendshipStatus){
		
		case .noRelationship:
			FirebaseAPI.sendFriendRequestTo(friendId: sender.cardUser.id);
			break;
		case .invited:
			break;
		case .accepted:
			self.navigationController?.pushViewController(BAChatController(withUser: sender.cardUser), animated: true);
			break;
		default:break;
			
		}
	}
	
	func userCardDidClick(sender: BAUserCard) {
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
			
			let nextView = BAProfileController(user: sender.cardUser);
			
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
