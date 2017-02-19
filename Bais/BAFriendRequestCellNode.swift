//
//  BATableCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 19/1/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol BAFriendRequestCellNodeDelegate: class {
	func friendRequestCellNodeAcceptedInvitation(_ friendRequestCellNode: BAFriendRequestCellNode)
}

class BAFriendRequestCellNode: ASCellNode {
	
	// add accept / reject
	var cardUser: User!
	let imageNode = ASNetworkImageNode()
	let nameNode = ASTextNode()
	var acceptButtonEnabled = true
	let acceptButtonNode = ASButtonNode()
	weak var delegate: BAFriendRequestCellNodeDelegate?
	
	required init(with user: User) {
		super.init()
		
		cardUser = user
		
		imageNode.setURL(URL(string: user.profilePicture), resetToDefault: false)
		imageNode.shouldRenderProgressImages = true
		imageNode.contentMode = .scaleAspectFill
		imageNode.imageModificationBlock = { image in
			var modifiedImage: UIImage!
			let rect = CGRect(origin: CGPoint(0, 0), size: image.size)
			
			UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
			let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 60, height: 60))
			maskPath.addClip()
			image.draw(in: rect)
			modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return modifiedImage
		}
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: UIColor.black]
		
		nameNode.attributedText = NSAttributedString(string: user.firstName, attributes: nameAttributes)
		
		acceptButtonNode.setTitle("ACCEPT", with: UIFont.systemFont(ofSize: 16, weight: UIFontWeightBold), with: ColorPalette.grey, for: [])
		acceptButtonNode.addTarget(self, action: #selector(pressedAcceptButton(_:)), forControlEvents: .touchUpInside)
		acceptButtonNode.addTarget(self, action: #selector(buttonBlocker(_:)), forControlEvents: .touchDragInside)
		acceptButtonNode.addTarget(self, action: #selector(buttonBlocker(_:)), forControlEvents: .touchDragOutside)
		acceptButtonNode.addTarget(self, action: #selector(buttonUnlocker(_:)), forControlEvents: .touchUpOutside)
		
		addSubnode(imageNode)
		addSubnode(nameNode)
		addSubnode(acceptButtonNode)
	}
	
	func pressedAcceptButton(_ sender: UIButton){
		if (acceptButtonEnabled){
			delegate?.friendRequestCellNodeAcceptedInvitation(self)
		} else {
			acceptButtonEnabled = true
		}
	}
	
	func buttonUnlocker(_ sender: UIButton){
		acceptButtonEnabled = true
	}
	
	func buttonBlocker(_ sender: UIButton){
		acceptButtonEnabled = false
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// imagen
		let imagePlace = ASRatioLayoutSpec(ratio: 1, child: imageNode)
		imagePlace.style.maxWidth = ASDimension(unit: .points, value: 60)
		
		// vertical stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .center
		verticalStack.children = [nameNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: verticalStack)
		
		// horizontal spacer
		let spacerSpec = ASLayoutSpec()
		spacerSpec.style.flexGrow = 1.0
		spacerSpec.style.flexShrink = 1.0
		
		// accept button
		acceptButtonNode.style.preferredSize = CGSize(width: 100, height: 50)
		
		// horizontal stack
		let horizontalStack = ASStackLayoutSpec.horizontal()
		horizontalStack.alignItems = .center // center items vertically in horiz stack
		horizontalStack.justifyContent = .start // justify content to left
		horizontalStack.style.flexShrink = 1.0
		horizontalStack.style.flexGrow = 1.0
		horizontalStack.children = [imagePlace, textInsetSpec, spacerSpec, acceptButtonNode]
		
		return ASInsetLayoutSpec (insets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 0), child: horizontalStack)
	}
}
