//
//  BAEditBasicUserInfoCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 10/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class BAEditBasicUserInfoCellNode: ASCellNode {
	
	let nameAndAgeNode = ASTextNode()
	let nationalityNode = ASTextNode()
	
	required init(with user: User) {
		super.init()
		
		let nameAndAgeAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		nameAndAgeNode.attributedText = NSAttributedString(string: user.firstName + ", " + String(user.age), attributes: nameAndAgeAttributes)
		
		let distanceAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		nationalityNode.attributedText = NSAttributedString(string: user.nationality, attributes: distanceAttributes)
		nationalityNode.maximumNumberOfLines = 1
		
		self.addSubnode(nameAndAgeNode)
		self.addSubnode(nationalityNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		// vertical stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .start
		verticalStack.justifyContent = .spaceBetween
		verticalStack.spacing = 6
		verticalStack.children = [nameAndAgeNode, nationalityNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: 17.5, left: 15, bottom: 17.5, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: verticalStack)
		
		return textInsetSpec
	}
	
}
