//
//  BAImageCarouselCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 4/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Foundation

class BAImageCarouselCellNode: ASCellNode {
	
	let imageNode = ASNetworkImageNode()
	var imageRatio: CGFloat = 0
	
	required init(with event: Event){
		super.init()
		imageRatio = 0.5
		imageNode.setURL(URL(string: event.imageUrl), resetToDefault: false)
		commonInit()
	}
	
	required init(with user: User) {
		super.init()
		imageRatio = 1
		imageNode.setURL(URL(string: user.profilePicture), resetToDefault: false)
		commonInit()
	}
	
	func commonInit(){
		imageNode.shouldRenderProgressImages = true
		imageNode.contentMode = .scaleAspectFill
		
		addSubnode(imageNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// imagen
		let imageLayout = ASRatioLayoutSpec(ratio: imageRatio, child: imageNode)
		imageLayout.style.minWidth = ASDimension(unit: .points, value: constrainedSize.max.width)
		
		return imageLayout
	}
}
