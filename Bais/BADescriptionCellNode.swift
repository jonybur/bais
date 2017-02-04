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
	
	required init(with user: User) {
		super.init()
		
		let paragraphAttributes = NSMutableParagraphStyle()
		paragraphAttributes.lineSpacing = 5
		
		let descriptionAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
			NSForegroundColorAttributeName: ColorPalette.grey,
			NSParagraphStyleAttributeName: paragraphAttributes]
		
		
		descriptionNode.attributedText = NSAttributedString(string: "Soy poco, y de lo poco que soy, poco entiendo. Sabes de mí lo que te dejo ver. Miedo al fracaso, pánico al rechazo, terror al olvido.\nAmante de los animales, el deporte y del rock.\nAdicta a las golosinas🍬 y las uvas🍇.\nViajar por todo el mundo✈️.", attributes: descriptionAttributes)
		
		self.addSubnode(descriptionNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		// text inset
		let textInsets = UIEdgeInsets(top: 17.5, left: 15, bottom: 17.5, right: 20)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: descriptionNode)
		
		return textInsetSpec
	}
	
}
