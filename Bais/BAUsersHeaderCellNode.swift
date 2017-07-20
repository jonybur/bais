//
//  BATableCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 19/1/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop

protocol BAUsersHeaderCellNodeDelegate: class {
	func usersHeaderCellNodeDidClickButton(_ usersViewCell: BAUsersHeaderCellNode);
}

// add a delegate here to be able switch around
class BAUsersHeaderCellNode: ASCellNode {
	
	weak var delegate: BAUsersHeaderCellNodeDelegate?
	let nameNode = ASTextNode()
	let buttonNode = ASButtonNode()
	var currentMode: UsersDisplayMode = .distance
	var blockButton: Bool = false
	var location: String?
	
	enum UsersDisplayMode: String{
		case distance = "distance", country = "country"
		
		func next() -> UsersDisplayMode {
			switch self {
			case .distance:
				return .country;
			default:
				return .distance;
			}
		}
	}
	
	init(with location: String) {
		super.init()
		
		self.location = location
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.init(name: "SourceSansPro-Bold", size: 28),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		nameNode.attributedText = NSAttributedString(string: "All Countries", attributes: nameAttributes)
		buttonNode.setImage(UIImage(named:"country-button"), for: [])
		
		self.selectionStyle = .none
		
		addSubnode(self.nameNode)
		addSubnode(self.buttonNode)
		
		buttonNode.addTarget(self, action: #selector(self.buttonPressed(_:)), forControlEvents: .touchUpInside)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		buttonNode.style.preferredSize = CGSize(width: 50, height: 50)
		buttonNode.style.flexShrink = 1.0

		let spacerSpec = ASLayoutSpec()
		spacerSpec.style.flexGrow = 1.0
		spacerSpec.style.flexShrink = 1.0
		
		// horizontal stack
		let horizontalStack = ASStackLayoutSpec.horizontal()
		horizontalStack.alignItems = .center
		horizontalStack.justifyContent = .start
		horizontalStack.style.flexShrink = 1.0
		horizontalStack.style.flexGrow = 1.0
		horizontalStack.children = [nameNode, spacerSpec, buttonNode]
		
		// move down
		let insetSpec = ASInsetLayoutSpec()
		insetSpec.insets = UIEdgeInsets(top: 20, left: 2.5, bottom: 0, right: 2.5)
		insetSpec.child = horizontalStack

		return insetSpec
	}
	
//MARK: - BAUsersHeaderCellNodeDelegate methods
	func buttonPressed(_ sender: UIButton){
		if (blockButton){
			return
		}
		blockButton = true
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.init(name: "SourceSansPro-Bold", size: 28),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		switch (currentMode) {
		case .distance:
            nameNode.attributedText = NSAttributedString(string: "Only " + location!, attributes: nameAttributes)
			buttonNode.setImage(UIImage(named:"distance-button"), for: [])
			break
		case .country:
            nameNode.attributedText = NSAttributedString(string: "All Countries", attributes: nameAttributes)
			buttonNode.setImage(UIImage(named:"country-button"), for: [])
			break
		}
		
		// animates the check
		let spring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY);
		spring?.velocity = NSValue(cgPoint: CGPoint(x: -5, y: -5));
		spring?.springBounciness = 5;
		spring?.completionBlock =  {(animation, finished) in
			self.blockButton = !self.blockButton
		}
		sender.pop_add(spring, forKey: "sendAnimation");

		currentMode = currentMode.next()
		
		delegate?.usersHeaderCellNodeDidClickButton(self);
	}
}
