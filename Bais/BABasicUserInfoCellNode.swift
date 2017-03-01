//
//  BABasicUserInfoCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 4/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class BABasicUserInfoCellNode: ASCellNode {
	
	let nameAndAgeNode = ASTextNode()
	let distanceNode = ASTextNode()
	let nationalityNode = ASTextNode()
	
	required init(with user: User) {
		super.init()
		
		let nameAndAgeAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		var nameAndAgeString = user.firstName
		if (user.age > 0){
			nameAndAgeString += ", " + String(user.age)
		}
		nameAndAgeNode.attributedText = NSAttributedString(string: nameAndAgeString, attributes: nameAndAgeAttributes)
		
		let distanceAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		let distanceString = user.location.distance(from: CurrentUser.location!).redacted()
		distanceNode.attributedText = NSAttributedString(string: distanceString, attributes: distanceAttributes)
		distanceNode.maximumNumberOfLines = 1
		
		nationalityNode.attributedText = NSAttributedString(string: user.country, attributes: distanceAttributes)
		nationalityNode.maximumNumberOfLines = 1
			
		self.addSubnode(nameAndAgeNode)
		self.addSubnode(distanceNode)
		self.addSubnode(nationalityNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		// vertical stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .start
		verticalStack.justifyContent = .spaceBetween
		verticalStack.spacing = 6
		verticalStack.children = [nameAndAgeNode, nationalityNode, distanceNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: 17.5, left: 15, bottom: 17.5, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: verticalStack)
		
		return textInsetSpec
	}
	
}
