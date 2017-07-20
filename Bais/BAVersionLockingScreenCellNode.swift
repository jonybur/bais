//
//  BAVersionLockingScreenCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 28/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BAVersionLockingScreenCellNode: ASDisplayNode{
	let topImageNode = ASImageNode()
	let titleNode = ASTextNode()
	let descriptionNode = ASTextNode()
	
	required override init() {
		super.init()
		
		topImageNode.image = UIImage(named: "version-lock")
		
		let titleAttributes = [
			NSFontAttributeName: UIFont.init(name: "SourceSansPro-Bold", size: 28),
			NSForegroundColorAttributeName: ColorPalette.grey]
		titleNode.attributedText = NSAttributedString(string: "Update required", attributes: titleAttributes)
		
		let titleParagraphStyle = NSMutableParagraphStyle()
		titleParagraphStyle.alignment = .center
		
		let descriptionAttributes = [
			NSFontAttributeName: UIFont.init(name: "SourceSansPro-Regular", size: 14),
			NSForegroundColorAttributeName: ColorPalette.grey,
			NSParagraphStyleAttributeName: titleParagraphStyle]
		
		descriptionNode.attributedText = NSAttributedString(string: "In order to keep using the app,\nan update is required.\n\nPlease go to the AppStore and download\nthe latest version of BAIS.", attributes: descriptionAttributes)
		
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
