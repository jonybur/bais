//
//  BAEditImageCarouselCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 10/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Foundation

protocol BAEditImageCarouselCellNodeDelegate: class {
	func editImageCarouselNodeDidClickEditImageButton()
}

class BAEditImageCarouselCellNode: ASCellNode {
	let imageNode = ASNetworkImageNode()
	let editImageButton = ASButtonNode()
	var imageRatio: CGFloat = 0
	weak var delegate: BAEditImageCarouselCellNodeDelegate?
	
	required init(with user: User) {
		super.init()
		
		imageRatio = 1
		imageNode.setURL(URL(string: user.profilePicture), resetToDefault: false)
		imageNode.shouldRenderProgressImages = true
		imageNode.contentMode = .scaleAspectFill
		
		editImageButton.setImage(UIImage(named: "edit-button"), for: [])
		editImageButton.addTarget(self, action: #selector(editImageButtonPressed(_:)), forControlEvents: .touchUpInside)
		
		addSubnode(imageNode)
		addSubnode(editImageButton)
	}
	
	func editImageButtonPressed(_ sender: UIButton){
		delegate?.editImageCarouselNodeDidClickEditImageButton()
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// imagen
		let imageLayout = ASRatioLayoutSpec(ratio: imageRatio, child: imageNode)
		imageLayout.style.minWidth = ASDimension(unit: .points, value: constrainedSize.max.width)
		
		// inset spec
		let editButtonInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 15)
		let editButtonSpec = ASInsetLayoutSpec(insets: editButtonInset, child: editImageButton)
		
		// text stack
		let textStack = ASStackLayoutSpec()
		textStack.direction = .vertical
		textStack.alignItems = .end
		textStack.justifyContent = .end
		textStack.children = [editButtonSpec]
		
		// overlay imagen + texto
		let overlayLayout = ASOverlayLayoutSpec(child: imageLayout, overlay: textStack)
		overlayLayout.style.flexBasis = ASDimension (unit: .fraction, value: 0.8)
		overlayLayout.style.flexShrink = 1
		
		return overlayLayout
	}
}
