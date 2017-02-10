//
//  BASettingsButtonElementCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 9/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BASettingsButtonElementCellNode: ASButtonNode{
	
	let titleTextNode = ASTextNode()
	
	required init(title: String) {
		super.init()
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		titleTextNode.attributedText = NSAttributedString(string: title, attributes: nameAttributes)
				
		self.addSubnode(titleNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// text inset
		let textInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: titleTextNode)
		
		let centerSpec = ASStackLayoutSpec()
		centerSpec.child = textInsetSpec
		centerSpec.style.width = ASDimension(unit: .points, value: constrainedSize.max.width)
		
		return centerSpec
	}
}
