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
	
	required init() {
		super.init()
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		return ASSpec()
	}
	
}
