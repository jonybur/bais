//
//  BABasicEventInfoCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 7/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class BABasicEventInfoCellNode: ASCellNode {
	
	let nameNode = ASTextNode()
	let dateNode = ASTextNode()
	let placeNode = ASTextNode()
	
	required init(with event: Event) {
		super.init()
		
		let nameAndAgeAttributes = [
			NSFontAttributeName: UIFont.init(name: "Nunito-Bold", size: 24),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		nameNode.attributedText = NSAttributedString(string: event.name, attributes: nameAndAgeAttributes)
		
		let distanceAttributes = [
			NSFontAttributeName: UIFont.init(name: "Nunito-Regular", size: 14),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		dateNode.attributedText = NSAttributedString(string: event.redactedDate(), attributes: distanceAttributes)
		dateNode.maximumNumberOfLines = 1
		
		placeNode.attributedText = NSAttributedString(string: event.place.street, attributes: distanceAttributes)
		placeNode.maximumNumberOfLines = 1
		
		addSubnode(nameNode)
		addSubnode(dateNode)
		addSubnode(placeNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		// vertical stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .start
		verticalStack.justifyContent = .spaceBetween
		verticalStack.spacing = 6
		verticalStack.children = [nameNode, dateNode, placeNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: 17.5, left: 15, bottom: 17.5, right: 10)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: verticalStack)
		
		return textInsetSpec
	}
	
}
