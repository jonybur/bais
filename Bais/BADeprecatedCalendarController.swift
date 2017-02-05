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
import pop
import DGActivityIndicatorView
import ESTabBarController

class BADeprecatedCalendarController : UIViewController, EventCardDelegate{
	
	var animating : Bool = false;
    var scrollNode : ASScrollNode = ASScrollNode();
	
	let activityIndicatorView = DGActivityIndicatorView(type: .ballScale,
	                                                    tintColor: ColorPalette.orange,
	                                                    size: 75);
	
    override func viewDidLoad() {
        
        super.viewDidLoad();
		
		automaticallyAdjustsScrollViewInsets = false;
		
        view.backgroundColor = ColorPalette.white;
		
		activityIndicatorView!.frame = CGRect(x: (ez.screenWidth - 75) / 2,
		                                      y: (ez.screenHeight - 75) / 2,
		                                      width: 75, height: 75);
		
		self.view.addSubview(activityIndicatorView!);
		activityIndicatorView?.startAnimating();
		
		/*
		async {
			CloudController.getFacebookEvents();
		}
		*/
    }
	
	// gets the notifications
    @objc func initializeInterface(_ notification: Notification) {
		
		var yPosition : CGFloat = GradientBar.height + 10;
		
		/*
		for event in FetchedContent.facebookEvents{
			
			if ((event.startTime as Date) < Date() &&
				(event.endTime as Date) < Date()) {
				continue;
			}
			
			let userCard : BAEventCard = BAEventCard(event: event, yPosition: yPosition);
			userCard.delegate = self;
			self.scrollNode.addSubnode(userCard);
			yPosition += userCard.frame.height + 10;
		}
		*/
		
		self.scrollNode.frame = CGRect(x:0, y:0, width: ez.screenWidth, height: ez.screenHeight);
		self.scrollNode.view.contentSize = CGSize(width: ez.screenWidth, height: yPosition + 100);
		self.view.addSubview(self.scrollNode.view);
		
		self.scrollNode.view.setContentOffset(CGPoint(x:0, y: 0), animated: false);
		
		activityIndicatorView?.removeFromSuperview();
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
    }
	
	// ASEventCard delegate methods
	func eventCardDidClick(sender: BAEventCard) {
		
		if (animating){
			return;
		}
		
		animating = true;
		
		// animates the check
		let spring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY);
		spring?.velocity = NSValue(cgPoint: CGPoint(x: -5, y: -5));
		spring?.springBounciness = 5;
		spring?.completionBlock = {(animation, finished) in
			
			let nextView = BAEventController(event: sender.facebookEvent);
			
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
