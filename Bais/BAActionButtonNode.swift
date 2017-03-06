//
//  BADetailActionButtonNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 14/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class BAActionButtonNode: ASButtonNode{
	override init(){
		super.init()
		
		backgroundColor = ColorPalette.orange
		frame = CGRect(x: ez.screenWidth / 2 - ez.screenWidth / 4, y: ez.screenHeight - 60, width: ez.screenWidth / 2, height: 50)
		let yourCarefullyDrawnPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), cornerRadius: 20)
		let maskForYourPath = CAShapeLayer()
		maskForYourPath.path = yourCarefullyDrawnPath.cgPath
		layer.mask = maskForYourPath
	}
	
	func setButtonTitle(_ title: String){
		setTitle(title, with: UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular), with: .white, for: [])
	}
}

class BAFriendshipActionButtonNode: BAActionButtonNode{

	weak var delegate: BAChatHeaderCellNodeDelegate?
	var friendshipStatus: FriendshipStatus = .noRelationship
	var blockButton = false
	
	init(with friendshipStatus: FriendshipStatus) {
		super.init()
		self.friendshipStatus = friendshipStatus
		setFriendshipAction()
		//self.addTarget(self, action: #selector(self.buttonPressed(_:)), forControlEvents: .touchUpInside)
	}
	
	func setFriendshipAction(){
		switch (friendshipStatus){
		case .accepted:
			setButtonTitle("Chat")
			style.preferredSize = CGSize(width: 300, height: 50)
			break;
		case .invitationSent:
			setButtonTitle("Invite sent")
			style.preferredSize = CGSize(width: 350, height: 50)
			break;
		case .invitationReceived:
			setButtonTitle("Invited you")
			style.preferredSize = CGSize(width: 350, height: 50)
			break;
		default:
			setButtonTitle("Invite")
			style.preferredSize = CGSize(width: 300, height: 50)
			break;
		}
	}
}

class BADetailActionButtonNode: BAActionButtonNode {
	
	var allowsDone = false
	
	override init() {
		super.init()
		style.preferredSize = CGSize(width: 300, height: 50)
		setButtonTitle("Done")
		alpha = 0.5
	}
	
	func enable(){
		alpha = 1
		allowsDone = true
	}
	
}
