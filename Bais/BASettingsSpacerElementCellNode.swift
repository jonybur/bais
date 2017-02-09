//
//  BASettingsSpacerElementCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 9/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BASettingsSpacerElementCellNode: ASCellNode{
	
	required override init() {
		super.init()
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let layoutSpec = ASLayoutSpec()
		layoutSpec.style.flexGrow = 1
		layoutSpec.style.flexShrink = 1
		layoutSpec.style.minHeight = ASDimension(unit: .points, value: 25)
		return layoutSpec
	}
	
}
