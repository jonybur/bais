//
//  BASettingsHeaderElementCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 9/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BASettingsHeaderElementCellNode: ASCellNode{
	
	let titleNode = ASTextNode()
	
	required init(title: String) {
		super.init()
		
		let distanceAttributes = [
			NSFontAttributeName: UIFont.init(name: "SourceSansPro-Regular", size: 14),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		titleNode.attributedText = NSAttributedString(string: title, attributes: distanceAttributes)
		titleNode.maximumNumberOfLines = 1
		
		self.addSubnode(titleNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// text inset
		let textInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: titleNode)
		
		return textInsetSpec
	}
	
}
