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
	
	var session: Session!
	let imageNode = ASNetworkImageNode()
	let nameNode = ASTextNode()
	let lastMessageNode = ASTextNode()
	
	required init(with session: Session) {
		super.init()
		
		self.session = session
		
		var otherUser: User!
		for user in session.participants{
			if (user.id != FirebaseService.currentUserId){
				otherUser = user
				break
			}
		}
		
		imageNode.setURL(URL(string: otherUser.profilePicture), resetToDefault: false)
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
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		nameNode.attributedText = NSAttributedString(string: otherUser.firstName, attributes: nameAttributes)
		
		let lastMessageAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		lastMessageNode.attributedText = NSAttributedString(string: "", attributes: lastMessageAttributes)
		
		addSubnode(imageNode)
		addSubnode(nameNode)
		addSubnode(lastMessageNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// imagen
		let imagePlace = ASRatioLayoutSpec(ratio: 1, child: imageNode)
		imagePlace.style.maxWidth = ASDimension(unit: .points, value: 60)
		
		// vertical stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .start
		verticalStack.children = [nameNode, lastMessageNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: verticalStack)
		
		// horizontal stack
		let horizontalStack = ASStackLayoutSpec()
		horizontalStack.direction = .horizontal
		horizontalStack.alignItems = .center
		horizontalStack.children = [imagePlace, textInsetSpec]
		
		return ASInsetLayoutSpec (insets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10), child: horizontalStack)
	}
}
