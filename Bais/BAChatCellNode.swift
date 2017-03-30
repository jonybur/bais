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
	let notificationCountNode = ASImageNode()
	let notificationCountTextNode = ASTextNode()
	let lastMessageNode = ASTextNode()
	
	required init(with session: Session) {
		super.init()
		
		self.session = session
		
		notificationCountNode.image = UIImage(named: "empty-circle")
		
		var otherUser: User!
		for user in session.participants{
			if (user.id != FirebaseService.currentUserId){
				otherUser = user
				break
			}
		}
		
		if (otherUser == nil){
			return
		}
		// FATAL BUG:
		//	 otherUser == nil
		//	 session.participants.count == 0
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
		
		lastMessageNode.attributedText = NSAttributedString(string: session.lastMessage.text, attributes: lastMessageAttributes)
		
		if (session.unreadCount > 0){
			let notificationCountAttributes = [
				NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
				NSForegroundColorAttributeName: UIColor.white]
			let unreadCount = String(session.unreadCount)
			notificationCountTextNode.attributedText = NSAttributedString(string: unreadCount, attributes: notificationCountAttributes)
		}
		
		addSubnode(imageNode)
		addSubnode(nameNode)
		addSubnode(lastMessageNode)
		addSubnode(notificationCountNode)
		addSubnode(notificationCountTextNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// imagen
		let imagePlace = ASRatioLayoutSpec(ratio: 1, child: imageNode)
		imagePlace.style.maxWidth = ASDimension(unit: .points, value: 60)
		
		if (session.unreadCount > 0){
			lastMessageNode.style.maxWidth = ASDimension(unit: .points, value: 175)
		}else{
			lastMessageNode.style.maxWidth = ASDimension(unit: .points, value: 260)
		}
		lastMessageNode.maximumNumberOfLines = 1
		
		// vertical stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .start
		verticalStack.children = [nameNode, lastMessageNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: verticalStack)
		
		// horizontal spacer
		let spacerSpec = ASLayoutSpec()
		spacerSpec.style.flexGrow = 1.0
		spacerSpec.style.flexShrink = 1.0
		
		// horizontal stack
		let horizontalStack = ASStackLayoutSpec()
		horizontalStack.alignItems = .center
		horizontalStack.direction = .horizontal
		horizontalStack.style.flexShrink = 1.0
		horizontalStack.style.flexGrow = 1.0
		
		// notification node
		if (session.unreadCount > 0){
			let unreadCount = String(session.unreadCount)
			if(unreadCount.characters.count == 1){
				notificationCountTextNode.style.layoutPosition = CGPoint(x: 8, y: 4)
			} else if(unreadCount.characters.count == 2){
				notificationCountTextNode.style.layoutPosition = CGPoint(x: 4, y: 4)
			}
			
			let notificationCountLayout = ASAbsoluteLayoutSpec(sizing: .sizeToFit, children: [notificationCountNode, notificationCountTextNode])
			let notificationInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 17.5)
			let notificationInsetsSpec = ASInsetLayoutSpec(insets: notificationInsets, child: notificationCountLayout)

			horizontalStack.children = [imagePlace, textInsetSpec, spacerSpec, notificationInsetsSpec]
		}else{
			horizontalStack.children = [imagePlace, textInsetSpec]
		}
		
		return ASInsetLayoutSpec (insets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10), child: horizontalStack)
	}
}
