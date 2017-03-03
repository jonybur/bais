//
//  BAEmptyStateCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 2/3/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BAEmptyStateFriendRequestsCellNode: BAEmptyStateCellNode{
	init(){
		super.init(title: "You don't have any\nfriend requests.", image: UIImage(named: "BaisLogo")!)
	}
}

class BAEmptyStateMessagesCellNode: BAEmptyStateCellNode{
	init(){
		super.init(title: "You don't have any messages.", image: UIImage(named: "BaisLogo")!)
	}
}

class BAEmptyStateCellNode: ASCellNode {
	
	let titleNode = ASTextNode()
	let imageNode = ASImageNode()
	
	init(title: String, image: UIImage) {
		super.init()
		
		self.frame = CGRect(x: 0, y: 150, width: ez.screenWidth, height: ez.screenHeight - 300)
		
		let titleParagraphStyle = NSMutableParagraphStyle()
		titleParagraphStyle.alignment = .center
		
		let titleAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: ColorPalette.grey,
			NSParagraphStyleAttributeName: titleParagraphStyle]
		titleNode.attributedText = NSAttributedString(string: title, attributes: titleAttributes)
		
		imageNode.image = image
		
		addSubnode(imageNode)
		addSubnode(titleNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		let insetSpec = ASInsetLayoutSpec(insets: titleInsets, child: titleNode)
		let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: insetSpec)
		
		imageNode.style.preferredSize = CGSize(width: 150, height: 150)
		
		let stackSpec = ASStackLayoutSpec()
		stackSpec.direction = .vertical
		stackSpec.spacing = 15
		stackSpec.justifyContent = .center
		stackSpec.alignItems = .center
		stackSpec.children = [imageNode, centerSpec]
		
		return stackSpec
	}
	
}
