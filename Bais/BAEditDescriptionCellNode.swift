//
//  BAEditDescriptionCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 10/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class BAEditDescriptionCellNode: ASCellNode {
	
	let descriptionNode = ASEditableTextNode()
	
	required init(with user: User) {
		super.init()

		let paragraphAttributes = NSMutableParagraphStyle()
		paragraphAttributes.lineSpacing = 5
		
		let descriptionAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
			NSForegroundColorAttributeName: ColorPalette.grey,
			NSParagraphStyleAttributeName: paragraphAttributes]
		
		let placeholderAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
			NSForegroundColorAttributeName: ColorPalette.lightGrey,
			NSParagraphStyleAttributeName: paragraphAttributes]
		
		if (user.about.characters.count == 0){
			descriptionNode.attributedText = NSAttributedString(string: "Write about yourself", attributes: placeholderAttributes)
		}else{
			descriptionNode.attributedText = NSAttributedString(string: user.about, attributes: descriptionAttributes)
		}
		
		addSubnode(descriptionNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// text inset
		let textInsets = UIEdgeInsets(top: 17.5, left: 15, bottom: 17.5, right: 20)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: descriptionNode)
		
		return textInsetSpec
	}
	
}
