//
//  FriendsScreen.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 6/8/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import AsyncDisplayKit
import ESTabBarController
import pop

class BAEventController : UIViewController, UIScrollViewDelegate{
	
	var scrollNode : ASScrollNode = ASScrollNode();
	var facebookEvent : Event = Event();
	let coverImage : ASNetworkImageNode = ASNetworkImageNode();
	var currentStatus : RSVPStatus = .Declined;
	
	var singleButton : ASButtonNode = ASButtonNode();
	var leftButton : ASButtonNode = ASButtonNode();
	var rightButton : ASButtonNode = ASButtonNode();
	
	convenience init(event : Event){
		self.init();
		facebookEvent = event;
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		
		automaticallyAdjustsScrollViewInsets = false;
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.setRSVPStatus(_:)),
		                                       name: NSNotification.Name(eventRSVPStatus + facebookEvent.id), object: nil)
		
		self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
		self.navigationController?.interactivePopGestureRecognizer?.delegate = nil;
		
		view.backgroundColor = ColorPalette.white;
		
		initalizeInterface();
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		scrollNode.removeFromSupernode();
	}
	
	func initalizeInterface() {
		coverImage.frame = CGRect(x: 0, y: 0, width: ez.screenWidth, height: ez.screenWidth * 0.5);
		coverImage.setURL(URL(string: facebookEvent.imageUrl), resetToDefault: false);
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		
		let titleAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight),
		                       NSForegroundColorAttributeName: UIColor.black,
		                       NSParagraphStyleAttributeName: paragraphStyle]
		
		let descriptionAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
			NSForegroundColorAttributeName: UIColor.black]
		
		let titleLabel : UILabel = UILabel();
		titleLabel.frame = CGRect(20, coverImage.frame.maxY + 20, CGFloat(ez.screenWidth - 40), 45);
		titleLabel.attributedText = NSAttributedString(string: facebookEvent.name, attributes: titleAttributes);
		titleLabel.adjustsFontSizeToFitWidth = true;
		
		var yPosition : CGFloat = titleLabel.frame.maxY + 20;
		setRSVPButtons(yPosition);
		yPosition += 75;
		
		let backgroundCard : ASDisplayNode = ASDisplayNode();
		self.scrollNode.addSubnode(backgroundCard);
		
		if (facebookEvent.place.isValid()){
			setAddress(yPosition);
			yPosition += 30;
			let map : BAMapBox = BAMapBox(coordinate: self.facebookEvent.place.coordinates.coordinate, yPosition: yPosition);
			map.center = CGPoint(x: CGFloat(ez.screenWidth / 2), y: yPosition + BAMapBox.mapHeight / 2);
			yPosition += BAMapBox.mapHeight + 30;
			self.scrollNode.view.addSubview(map);
		}
		
		let descriptionView : UITextView = UITextView();
		descriptionView.frame = CGRect(20, yPosition, ez.screenWidth - 40, 10);
		descriptionView.attributedText = NSAttributedString(string: facebookEvent.description, attributes: descriptionAttributes);
		descriptionView.dataDetectorTypes = .link;
		descriptionView.isScrollEnabled = false;
		descriptionView.isEditable = false;
		let newSize = descriptionView.sizeThatFits(descriptionView.frame.size);
		descriptionView.frame.size = newSize;

		backgroundCard.frame = CGRect(10, 0, CGFloat(ez.screenWidth) - CGFloat(20), descriptionView.frame.maxY + 20);
		backgroundCard.backgroundColor = UIColor.white;
		backgroundCard.cornerRadius = 10;
		
		scrollNode.addSubnode(coverImage);
		scrollNode.view.addSubview(titleLabel);
		self.scrollNode.addSubnode(self.singleButton);
		self.scrollNode.addSubnode(self.leftButton);
		self.scrollNode.addSubnode(self.rightButton);
		scrollNode.view.addSubview(descriptionView);
		
		self.scrollNode.frame = CGRect(x:0, y:0, width: ez.screenWidth, height: ez.screenHeight);
		self.scrollNode.view.contentSize = CGSize(width: ez.screenWidth, height: backgroundCard.frame.height + 30);
		
		self.scrollNode.view.delegate = self;
		
		self.view.addSubnode(scrollNode);
		
		let realButton: ASImageNode = ASImageNode();
		realButton.frame = CGRect(x: 0, y: 0, width: 90, height: 80);
		realButton.addTarget(self, action: #selector(backPressed(sender:)), forControlEvents: .touchUpInside);
		
		let backButton: ASImageNode = ASImageNode();
		backButton.frame = CGRect(x: 20, y: 30, width: 35, height: 30);
		backButton.image = UIImage(named: "back-button");
		
		self.view.addSubnode(realButton);
		self.view.addSubnode(backButton);
	}
	
	func backPressed(sender : UIButton) {
		self.navigationController!.popViewController(animated: true);
	}

	// keeps the banner on top
	func scrollViewDidScroll(_ scrollView: UIScrollView) {

		if(scrollView.contentOffset.y < 0) {
			coverImage.position = CGPoint(x: coverImage.position.x,
			                              y: coverImage.frame.height / 2 + scrollView.contentOffset.y);
		}
	
	}
	
	func setAddress(_ yPosition : CGFloat){
		
		let addressAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight),
			NSForegroundColorAttributeName: UIColor.black]
		
		let addressLabel : UILabel = UILabel();
		addressLabel.frame = CGRect(20, yPosition, ez.screenWidth - 40, 20);
		addressLabel.adjustsFontSizeToFitWidth = true;
		
		var addressString : String = facebookEvent.place.name;
		if (facebookEvent.place.street.characters.count > 0){
			addressString += ", " + facebookEvent.place.street;
		}
		
		if(addressString.characters.count > 50){
			let range = addressString.startIndex..<addressString.characters.index(addressString.startIndex, offsetBy: 50);
			addressString = addressString.substring(with: range) + "...";
		}
		
		addressLabel.attributedText = NSAttributedString(string: addressString, attributes: addressAttributes);
		
		self.scrollNode.view.addSubview(addressLabel);
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated);
		CloudController.getRSVPStatus(facebookEvent.id, rsvpStatus: .Attending);
	}
	
	func setRSVPButtons(_ yPosition : CGFloat){
	
		let buttonHeight : CGFloat = 50;
		
		// could say "Going" or "Interested"
		self.singleButton.frame = CGRect(10, yPosition, ez.screenWidth - 20, buttonHeight);
		self.singleButton.addTarget(self, action: #selector(buttonPressed(sender:)), forControlEvents: .touchUpInside);
		self.singleButton.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0);
		
		// "Interested" button
		self.leftButton.frame = CGRect(10, yPosition, (ez.screenWidth - 20) / 2 - 1, buttonHeight);
		self.leftButton.addTarget(self, action: #selector(leftButtonPressed(sender:)), forControlEvents: .touchUpInside);
		self.leftButton.setImage(UIImage(named: "interested-button"), for: ASControlState());
		self.leftButton.setTitle("Interested        ", with: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium), with: ColorPalette.orange, for: ASControlState());
		self.leftButton.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0);
		
		// "Going" button
		self.rightButton.frame = CGRect(x: self.leftButton.frame.maxX + 1, y: yPosition, width: CGFloat((ez.screenWidth - 20) / 2), height: buttonHeight);
		self.rightButton.addTarget(self, action: #selector(rightButtonPressed(sender:)), forControlEvents: .touchUpInside);
		self.rightButton.setImage(UIImage(named: "plus-button"), for: ASControlState());
		self.rightButton.setTitle("Going       ", with: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium), with: ColorPalette.orange, for: ASControlState());
		self.rightButton.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0);
		
		self.singleButton.alpha = 0;
		self.leftButton.alpha = 1;
		self.rightButton.alpha = 1;
	}
	
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
			self.singleButton.setTitle("Interested      ", with: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium), with: ColorPalette.orange, for: ASControlState());
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
			self.singleButton.setTitle("Going      ", with: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium), with: ColorPalette.orange, for: ASControlState());
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


}
