//
//  BATableCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 19/1/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BAChatCellNode: ASCellNode {
	
	var cardUser: User!
	let imageNode = ASNetworkImageNode()
	let nameNode = ASTextNode()
	let lastMessageNode = ASTextNode()
	
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
		
		let lastMessageAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
			NSForegroundColorAttributeName: UIColor.black]
		
		lastMessageNode.attributedText = NSAttributedString(string: user.lastMessage, attributes: lastMessageAttributes)
		
		self.addSubnode(self.imageNode)
		self.addSubnode(self.nameNode)
		self.addSubnode(self.lastMessageNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		// imagen
		let imagePlace = ASRatioLayoutSpec(ratio: 1, child: imageNode)
		imagePlace.style.maxWidth = ASDimension(unit: .points, value: 60)
		
		// vertical stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .start
		verticalStack.children = [self.nameNode, self.lastMessageNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: verticalStack)
		
		// horizontal stack
		let horizontalStack = ASStackLayoutSpec()
		horizontalStack.direction = .horizontal
		horizontalStack.alignItems = .center
		horizontalStack.children = [imagePlace, textInsetSpec]
		
		return ASInsetLayoutSpec (insets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10), child: horizontalStack)
	}
}
