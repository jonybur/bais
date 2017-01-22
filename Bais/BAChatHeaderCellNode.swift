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
	
	required init(with user: User) {
		super.init()
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.baisOrange]
		
		nameNode.attributedText = NSAttributedString(string: "My Friends", attributes: nameAttributes)
		
		self.selectionStyle = .none
		
		self.addSubnode(self.nameNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// text inset
		let textInsets = UIEdgeInsets(top: 40, left: 10, bottom: 30, right: 0)
		let insetSpec = ASInsetLayoutSpec(insets: textInsets, child: nameNode)
		return insetSpec
	}
}
