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
		
		addSubnode(self.nameNode)
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
}
