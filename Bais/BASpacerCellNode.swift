//
//  BASpacerCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 4/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class BASpacerCellNode: ASCellNode {
	
	override init() {
		super.init()
        self.selectionStyle = .none
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.style.minHeight = ASDimension(unit: .points, value: 100)
		return verticalStack
	}
	
}
