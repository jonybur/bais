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
	
	override init() {
		super.init()
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.baisOrange]
		
		nameNode.attributedText = NSAttributedString(string: "Sorted by Distance", attributes: nameAttributes)
		
		self.addSubnode(self.nameNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// text inset
		let textInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
		let insetSpec = ASInsetLayoutSpec(insets: textInsets, child: nameNode)
		return insetSpec
	}
}
