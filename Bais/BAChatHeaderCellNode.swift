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

protocol BAChatHeaderCellNodeDelegate: class {
	func chatHeaderCellNodeDidClickButton(_ chatViewCell: BAChatHeaderCellNode);
}

// add a delegate here to be able switch around
class BAChatHeaderCellNode: ASCellNode {
	
	weak var delegate: BAChatHeaderCellNodeDelegate?
	let nameNode = ASTextNode()
	let buttonNode = ASButtonNode()
	var currentMode: ChatDisplayMode = .friends
	var blockButton: Bool = false
	
	enum ChatDisplayMode: String{
		case friends = "friends", requests = "requests"
		
		func next() -> ChatDisplayMode {
			switch self {
			case .friends:
				return .requests;
			default:
				return .friends;
			}
		}
	}
	
	required init(with user: User) {
		super.init()
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		nameNode.attributedText = NSAttributedString(string: "My Friends", attributes: nameAttributes)
		buttonNode.setImage(UIImage(named:"empty-invites-button"), for: [])

		buttonNode.addTarget(self, action: #selector(self.buttonPressed(_:)), forControlEvents: .touchUpInside)
		
		self.selectionStyle = .none

		self.addSubnode(self.nameNode)
		addSubnode(self.buttonNode)
	}
		
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		buttonNode.style.preferredSize = CGSize(width: 50, height: 50)
		buttonNode.style.flexShrink = 1.0
		
		let spacerSpec = ASLayoutSpec()
		spacerSpec.style.flexGrow = 1.0
		spacerSpec.style.flexShrink = 1.0
		
		// horizontal stack
		let horizontalStack = ASStackLayoutSpec.horizontal()
		horizontalStack.alignItems = .center // center items vertically in horiz stack
		horizontalStack.justifyContent = .start // justify content to left
		horizontalStack.style.flexShrink = 1.0
		horizontalStack.style.flexGrow = 1.0
		horizontalStack.children = [nameNode, spacerSpec, buttonNode]
		
		// move down
		let insetSpec = ASInsetLayoutSpec()
		insetSpec.insets = UIEdgeInsets(top: 40, left: 15, bottom: 30, right: 15)
		insetSpec.child = horizontalStack
		
		return insetSpec
	}
	
	//MARK: - BAChatHeaderCellNodeDelegate methods
	func buttonPressed(_ sender: UIButton){
		
		if (blockButton){
			return
		}
		blockButton = true
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		switch (currentMode) {
		case .requests:
			nameNode.attributedText = NSAttributedString(string: "My Friends", attributes: nameAttributes)
			buttonNode.setImage(UIImage(named:"empty-invites-button"), for: [])
			break
		case .friends:
			nameNode.attributedText = NSAttributedString(string: "Friend Requests", attributes: nameAttributes)
			buttonNode.setImage(UIImage(named:"messages-button"), for: [])
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
		
		delegate?.chatHeaderCellNodeDidClickButton(self);
	}

}