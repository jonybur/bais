//
//  BADescriptionCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 4/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class BADescriptionInfoCellNode: ASCellNode {
	
	let descriptionNode = ASTextNode()
	
	required init(with event: Event){
		super.init()
		commonInit(description: event.eventDescription)
	}
	
	required init(with user: User) {
		super.init()
		commonInit(description: user.about)
	}
	
	func commonInit(description: String){
		let paragraphAttributes = NSMutableParagraphStyle()
		paragraphAttributes.lineSpacing = 5
		
		let descriptionAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
			NSForegroundColorAttributeName: ColorPalette.grey,
			NSParagraphStyleAttributeName: paragraphAttributes]
		
		descriptionNode.attributedText = NSAttributedString(string: description, attributes: descriptionAttributes)
		
		self.addSubnode(descriptionNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// text inset
		let textInsets = UIEdgeInsets(top: 17.5, left: 15, bottom: 17.5, right: 20)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: descriptionNode)
		
		return textInsetSpec
	}
	
}
