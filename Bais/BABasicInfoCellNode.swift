//
//  BABasicInfoCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 4/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class BABasicInfoCellNode: ASCellNode {
	
	let nameAndAgeNode = ASTextNode()
	let distanceNode = ASTextNode()
	let flagNode = ASImageNode()
	
	required init(with user: User) {
		super.init()
		
		let nameAndAgeAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 22, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: ColorPalette.black]
		
		nameAndAgeNode.attributedText = NSAttributedString(string: user.firstName + ", " + String(user.age), attributes: nameAndAgeAttributes)
		
		let distanceAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		let distanceString = user.location.distance(from: CurrentUser.location!).redacted()
		distanceNode.attributedText = NSAttributedString(string: distanceString, attributes: distanceAttributes)
		distanceNode.maximumNumberOfLines = 1
		
		self.addSubnode(nameAndAgeNode)
		self.addSubnode(distanceNode)
		self.addSubnode(flagNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		// vertical stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .start
		verticalStack.justifyContent = .spaceBetween
		verticalStack.spacing = 10
		verticalStack.children = [nameAndAgeNode, distanceNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: 17.5, left: 15, bottom: 17.5, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: verticalStack)
		
		return textInsetSpec
	}
	
}
