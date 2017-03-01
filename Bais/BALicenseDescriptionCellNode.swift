//
//  BALicenseDescription.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 1/3/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BALicenseDescriptionCellNode: ASCellNode{

	let licenseText = ASTextNode()
	
	required init(license: String){
		super.init()
		
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		return ASLayoutSpec()
	}
	
}
