//
//  BALocationLockingScreenCell.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 28/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BALocationLockingScreenCellNode: ASDisplayNode{
	let topImageNode = ASImageNode()
	let titleNode = ASTextNode()
	let descriptionNode = ASTextNode()
	
	required override init() {
		super.init()
		
		topImageNode.image = UIImage(named: "BaisLogo")
		
		let titleAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.grey]
		titleNode.attributedText = NSAttributedString(string: "Where are you?", attributes: titleAttributes)
		
		let titleParagraphStyle = NSMutableParagraphStyle()
		titleParagraphStyle.alignment = .center
		
		let descriptionAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: ColorPalette.grey,
			NSParagraphStyleAttributeName: titleParagraphStyle]
		
		descriptionNode.attributedText = NSAttributedString(string: "In order to show you interesting people near you, Bais needs to know where you are.\n\nGo to Settings > Privacy > Location Services, and switch Bais to ON.", attributes: descriptionAttributes)
		
		addSubnode(topImageNode)
		addSubnode(titleNode)
		addSubnode(descriptionNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		topImageNode.style.preferredSize = CGSize(width: 175, height: 175)
		
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .center
		verticalStack.spacing = 15
		verticalStack.children = [topImageNode, titleNode, descriptionNode]
		
		let edgeInsets = UIEdgeInsets(top: 40, left: 15, bottom: 0, right: 15)
		let insetSpec = ASInsetLayoutSpec(insets: edgeInsets, child: verticalStack)
		
		return insetSpec
	}
	
}