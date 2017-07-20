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
		
		let licenseAttributes = [
			NSFontAttributeName: UIFont.init(name: "SourceSansPro-Regular", size: 14),
			NSForegroundColorAttributeName: ColorPalette.grey]
		licenseText.attributedText = NSAttributedString(string: license, attributes: licenseAttributes)
		
		addSubnode(licenseText)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 15, bottom: 30, right: 15), child: licenseText)
	}
	
}
