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
class BAUsersHeaderCellNode: ASCellNode {
	
	let nameNode = ASTextNode()
	let buttonNode = ASButtonNode()
	
	override init() {
		super.init()
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		nameNode.attributedText = NSAttributedString(string: "Sorted by Distance", attributes: nameAttributes)
		buttonNode.setImage(UIImage(named:"country-button"), for: [])
		
		self.addSubnode(self.nameNode)
		self.addSubnode(self.buttonNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// text inset
		let textInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: self.nameNode)
		
		// text inset
		// TODO: corner-right 
		buttonNode.style.preferredSize = CGSize(width: 50, height: 50)
		let buttonInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		let buttonInsetSpec = ASInsetLayoutSpec(insets: buttonInsets, child: self.buttonNode)
		
		// horizontal stack
		let horizontalStack = ASStackLayoutSpec()
		horizontalStack.direction = .horizontal
		horizontalStack.justifyContent = .end
		horizontalStack.alignItems = .stretch
		horizontalStack.children = [textInsetSpec, buttonInsetSpec]
		
		return horizontalStack
	}
}
