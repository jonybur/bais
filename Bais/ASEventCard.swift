//
//  UIUserCard.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 1/8/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop
import AwaitKit

protocol EventCardDelegate: class {
	func eventCardDidClick(sender: ASEventCard)
}

class ASEventCard : ASButtonNode{
	
	var singleButton : ASButtonNode = ASButtonNode();
	var leftButton : ASButtonNode = ASButtonNode();
	var rightButton : ASButtonNode = ASButtonNode();

	var currentStatus : RSVPStatus = .Declined;
	var facebookEvent : Event = Event();
	
	weak var delegate : EventCardDelegate?;
	
    init (event : Event, yPosition : CGFloat){
        super.init();
		
		facebookEvent = event;

		NotificationCenter.default.addObserver(self, selector: #selector(setRSVPStatus(_:)),
		                                       name: NSNotification.Name(eventRSVPStatus + event.id), object: nil)

		let xPosition : CGFloat = 10;
		let cardWidth : CGFloat = (ez.screenWidth) - xPosition * 2;
        let buttonHeight : CGFloat = 40;
        let cardHeight : CGFloat = cardWidth / 2 + buttonHeight;
		
        self.frame = CGRect(x: xPosition, y: yPosition, width: cardWidth, height: cardHeight);
		self.backgroundColor = UIColor.init(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1);
		
		// shoot on main thread (?)
		let photoHeight = cardHeight - buttonHeight;
		
		let imageNode = ASNetworkImageNode();
		imageNode.frame = CGRect(x: 0, y: 0, width: cardWidth, height: photoHeight);
		imageNode.setURL(URL(string: event.imageUrl), resetToDefault: false);
		imageNode.shouldRenderProgressImages = true;
		self.addTarget(self, action: #selector(entersEvent(sender:)), forControlEvents: .touchUpInside);
		
		// black gradient
		let gradientView: UIView = UIView(frame: CGRect(x: 0.0, y: imageNode.frame.height / 2, width: imageNode.frame.width, height: imageNode.frame.height / 2));
		let gradient: CAGradientLayer = CAGradientLayer();
		gradient.frame = gradientView.bounds;
		gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor];
		gradientView.layer.insertSublayer(gradient, at: 0);
		gradientView.alpha = 0.6;
		
		// could say "Going" or "Interested"
		self.singleButton.frame = CGRect(x: 0, y: cardHeight - buttonHeight, width: cardWidth, height: buttonHeight);
		self.singleButton.addTarget(self, action: #selector(buttonPressed(sender:)), forControlEvents: .touchUpInside);
		self.singleButton.backgroundColor = UIColor.white;
		
		// "Interested" button
		self.leftButton.frame = CGRect(x: 0, y: cardHeight - buttonHeight, width: cardWidth / 2 - 1, height: buttonHeight);
		self.leftButton.addTarget(self, action: #selector(leftButtonPressed(sender:)), forControlEvents: .touchUpInside);
		self.leftButton.setImage(UIImage(named: "interested-button"), for: ASControlState());
		self.leftButton.setTitleInMiddleAlignment("Interested        ", withFont: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium), withColor: ColorPalette.baisOrange, state: ASControlState());
		self.leftButton.backgroundColor = UIColor.white;
		
		// "Going" button
		self.rightButton.frame = CGRect(x: self.leftButton.frame.maxX + 1, y: cardHeight - buttonHeight, width: cardWidth / 2, height: buttonHeight);
		self.rightButton.addTarget(self, action: #selector(rightButtonPressed(sender:)), forControlEvents: .touchUpInside);
		self.rightButton.setImage(UIImage(named: "plus-button"), for: ASControlState());
		self.rightButton.setTitleInMiddleAlignment("Going       ", withFont: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium), withColor: ColorPalette.baisOrange, state: ASControlState());
		self.rightButton.backgroundColor = UIColor.white;
		
		self.singleButton.alpha = 0;
		self.leftButton.alpha = 1;
		self.rightButton.alpha = 1;
		
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
		
		let nameNode = ASTextNode();
		nameNode.frame = CGRect(x: 10, y: photoHeight - 45, width: cardWidth - 15, height: 20);
		nameNode.attributedText = NSAttributedString(string: event.name, attributes: nameAttributes);
		
		let distanceNode = ASTextNode();
		distanceNode.frame = CGRect(x:10, y: nameNode.frame.maxY, width: cardWidth - 15, height: 20);
		
		let calendar = Calendar.current
		let startDateComponents = (calendar as NSCalendar).components([.day, .month], from: event.startTime as Date);
		let endDateComponents = (calendar as NSCalendar).components([.day, .month], from: event.endTime as Date);

		var dateString : String = "";
		
		if (startDateComponents.day != endDateComponents.day){
			
			// September 30 - October 4
			let startDateFormatter = DateFormatter();
			startDateFormatter.dateFormat = "MMMM d '-' ";
			let startDateString = startDateFormatter.string(from: event.startTime as Date);
			
			let endDateFormatter = DateFormatter();
			endDateFormatter.dateFormat = "MMMM d";
			let endDateString = endDateFormatter.string(from: event.endTime as Date);
			
			dateString = startDateString + endDateString;

		} else {
		
			// Saturday, September 14 at 3:00 PM - 4:00 PM
			let startDateFormatter = DateFormatter();
			startDateFormatter.dateFormat = "EEEE',' MMMM d 'at' h:mm a '-' ";
			let startDateString = startDateFormatter.string(from: event.startTime as Date);
			
			let endDateFormatter = DateFormatter();
			endDateFormatter.dateFormat = "h:mm a";
			let endDateString = endDateFormatter.string(from: event.endTime as Date);
			
			dateString = startDateString + endDateString;
			
		}
		
		distanceNode.attributedText = NSAttributedString(string: dateString, attributes: distanceAttributes)
		
		// self.view isn't a node, so we can only use it on the main thread
	
		self.layer.cornerRadius = 10;
		self.view.clipsToBounds = true;
		self.view.addSubnode(imageNode);
		self.view.addSubview(gradientView);
		self.view.addSubnode(nameNode);
		self.view.addSubnode(distanceNode);
		self.view.addSubnode(self.singleButton);
		self.view.addSubnode(self.leftButton);
		self.view.addSubnode(self.rightButton);
		
		CloudController.getRSVPStatus(event.id, rsvpStatus: .Attending);
		
    }
	
	@objc func setRSVPStatus(_ notification: Notification) {
		
		self.leftButton.alpha = 0;
		self.rightButton.alpha = 0;
		self.singleButton.alpha = 0;
		
		switch((notification as NSNotification).userInfo!["status"]! as! String){
			
		case "Declined":
			currentStatus = .Declined;
			self.leftButton.alpha = 1;
			self.rightButton.alpha = 1;
			break;
			
		case "Maybe":
			currentStatus = .Maybe;
			self.singleButton.setImage(UIImage(named: "checked-button"), for: ASControlState());
			self.singleButton.setTitleInMiddleAlignment("Interested      ", withFont: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium), withColor: ColorPalette.baisOrange, state: ASControlState());
			self.singleButton.alpha = 1;
			
			// animates the check
			let spring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY);
			spring?.velocity = NSValue(cgPoint: CGPoint(x: 7, y: 7));
			spring?.springBounciness = 20;
			self.singleButton.imageNode.pop_add(spring, forKey: "sendAnimation");

			break;
			
		case "Attending":
			currentStatus = .Attending;
			self.singleButton.setImage(UIImage(named: "checked-button"), for: ASControlState());
			self.singleButton.setTitleInMiddleAlignment("Going      ", withFont: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium), withColor: ColorPalette.baisOrange, state: ASControlState());
			self.singleButton.alpha = 1;
			
			// animates the check
			let spring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY);
			spring?.velocity = NSValue(cgPoint: CGPoint(x: 7, y: 7));
			spring?.springBounciness = 20;
			self.singleButton.imageNode.pop_add(spring, forKey: "sendAnimation");
			
			break;
			
		default:
			break;
		}
	}
	
	// move to uiviewcontroller (eventscreen
	func entersEvent(sender : UIButton){
		delegate?.eventCardDidClick(sender: self)
	}
	
	
	// move these three button actions to calendarscreen, with own delegate
	func leftButtonPressed(sender : UIButton){
		CloudController.setNewRSVPStatus(self.facebookEvent.id, rsvpStatus: .Maybe);
		
		// animates the check
		let spin = POPSpringAnimation(propertyNamed: kPOPLayerRotation)
		spin?.fromValue = NSNumber(value: M_PI * 1 as Double)
		spin?.toValue = NSNumber(value: 0 as Int32)
		spin?.springBounciness = 5;
		spin?.velocity = NSNumber(value: 5 as Int32)
		self.leftButton.imageNode.pop_add(spin, forKey: "rotateAnimation")
	}
	
	func rightButtonPressed(sender : UIButton){
		CloudController.setNewRSVPStatus(self.facebookEvent.id, rsvpStatus: .Attending);
		
		// animates the check
		let spring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY);
		spring?.velocity = NSValue(cgPoint: CGPoint(x: 7, y: 7));
		spring?.springBounciness = 20;
		self.rightButton.imageNode.pop_add(spring, forKey: "sendAnimation");
	}
	
    func buttonPressed(sender : UIButton){
		
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet);
		
		if (currentStatus == .Maybe){
			alert.addAction(UIAlertAction(title: "Going", style: UIAlertActionStyle.default, handler: { action in
				CloudController.setNewRSVPStatus(self.facebookEvent.id, rsvpStatus: .Attending);
			}));
		} else if (currentStatus == .Attending){
			alert.addAction(UIAlertAction(title: "Interested", style: UIAlertActionStyle.default, handler: { action in
				CloudController.setNewRSVPStatus(self.facebookEvent.id, rsvpStatus: .Maybe);
			}));
		}
		
		alert.addAction(UIAlertAction(title: "Not Going", style: UIAlertActionStyle.default, handler: { action in
			CloudController.setNewRSVPStatus(self.facebookEvent.id, rsvpStatus: .Declined);
		}));
		
		alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil));

		var topVC = UIApplication.shared.keyWindow?.rootViewController
		while((topVC!.presentedViewController) != nil) {
			topVC = topVC!.presentedViewController;
		}
		
		topVC?.present(alert, animated: true, completion: nil);
		
    }
}
