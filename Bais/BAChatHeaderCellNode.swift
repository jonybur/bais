//
//  BATableCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 19/1/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

// add a delegate here to be able switch around
class BAChatHeaderCellNode: ASCellNode {
	
	let nameNode = ASTextNode()
	let buttonNode = ASButtonNode()
	
	required init(with user: User) {
		super.init()
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		nameNode.attributedText = NSAttributedString(string: "My Friends", attributes: nameAttributes)
		buttonNode.setImage(UIImage(named:"country-button"), for: [])
		
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
}
