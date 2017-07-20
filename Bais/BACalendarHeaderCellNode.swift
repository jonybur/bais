//
//  BACalendarHeaderCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 4/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop

// add a delegate here to be able switch modes
class BACalendarHeaderCellNode: ASCellNode {
	let nameNode = ASTextNode()
	
	required override init() {
		super.init()
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.init(name: "SourceSansPro-Bold", size: 28),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		nameNode.attributedText = NSAttributedString(string: "Discover Events", attributes: nameAttributes)
		
		self.selectionStyle = .none
		
		self.addSubnode(self.nameNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		// move down
		let insetSpec = ASInsetLayoutSpec()
		insetSpec.insets = UIEdgeInsets(top: 28, left: 3, bottom: 30, right: 15)
		insetSpec.child = nameNode
		
		return insetSpec
	}
}
