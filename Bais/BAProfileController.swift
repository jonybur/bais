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

class BAProfileController : UIViewController, UIScrollViewDelegate{
	
	var scrollNode : ASScrollNode = ASScrollNode();
	var thisUser : User = User();
	let coverImage : ASNetworkImageNode = ASNetworkImageNode();
	var currentStatus : RSVPStatus = .Declined;
	
	var singleButton : ASButtonNode = ASButtonNode();
	var leftButton : ASButtonNode = ASButtonNode();
	var rightButton : ASButtonNode = ASButtonNode();
	
	convenience init(user : User){
		self.init();
		thisUser = user;
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		
		automaticallyAdjustsScrollViewInsets = false;
		
		self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
		self.navigationController?.interactivePopGestureRecognizer?.delegate = nil;
		
		view.backgroundColor = ColorPalette.white;
		
		initalizeInterface();
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		scrollNode.removeFromSupernode();
	}
	
	func initalizeInterface() {
		coverImage.frame = CGRect(x: 10, y: 0, width: ez.screenWidth - 20, height: ez.screenWidth - 20);
		coverImage.setURL(URL(string: thisUser.profilePicture), resetToDefault: false);
		coverImage.contentMode = .scaleAspectFit;
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		
		let nameAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 22, weight: UIFontWeightRegular),
		                       NSForegroundColorAttributeName: UIColor.black]
		
		let descriptionAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
		                             NSForegroundColorAttributeName: UIColor.black]
		
		let titleLabel : UILabel = UILabel();
		titleLabel.frame = CGRect(25, coverImage.frame.maxY, CGFloat(ez.screenWidth - 40), 50);
		titleLabel.attributedText = NSAttributedString(string: thisUser.firstName, attributes: nameAttributes);
		titleLabel.adjustsFontSizeToFitWidth = true;
		
		var yPosition : CGFloat = titleLabel.frame.maxY + 20;
		
		let backgroundCard : ASDisplayNode = ASDisplayNode();
		self.scrollNode.addSubnode(backgroundCard);
		
		backgroundCard.frame = CGRect(10, -10, CGFloat(ez.screenWidth) - CGFloat(20), 400);
		backgroundCard.backgroundColor = UIColor.white;
		backgroundCard.cornerRadius = 10;
		
		scrollNode.addSubnode(coverImage);
		scrollNode.view.addSubview(titleLabel);
		self.scrollNode.addSubnode(self.singleButton);
		self.scrollNode.addSubnode(self.leftButton);
		self.scrollNode.addSubnode(self.rightButton);
		
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
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated);
	}
	
}
