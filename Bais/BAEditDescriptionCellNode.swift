//
//  BAEditDescriptionCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 10/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class BAEditDescriptionCellNode: ASCellNode, ASEditableTextNodeDelegate {
	
	let titleTextNode = ASTextNode()
	let descriptionNode = ASEditableTextNode()
	let buttonNode = ASButtonNode()
	
	required init(with user: User) {
		super.init()

		let paragraphAttributes = NSMutableParagraphStyle()
		paragraphAttributes.lineSpacing = 5
		
		descriptionNode.typingAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
			NSForegroundColorAttributeName: ColorPalette.grey,
			NSParagraphStyleAttributeName: paragraphAttributes]
		
		titleTextNode.attributedText = NSAttributedString(string: "About you", attributes: [
			NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: ColorPalette.grey])

		descriptionNode.attributedPlaceholderText = NSAttributedString(string: "Write about yourself",
		                                                               attributes: [
																		NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular),
																		NSForegroundColorAttributeName: ColorPalette.lightGrey,
																		NSParagraphStyleAttributeName: paragraphAttributes])
		
		descriptionNode.attributedText = NSAttributedString(string: user.about, attributes: descriptionNode.typingAttributes)
		
		descriptionNode.delegate = self
		
		addSubnode(titleTextNode)
		addSubnode(descriptionNode)
		addSubnode(buttonNode)
	}
	
	func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
		guard let attributedText = editableTextNode.attributedText else {
			return
		}
		// TODO: re-layout descriptionNode according to attributedText length
		if (attributedText.length > 400){
			let range = NSRange(location: 0, length: 400)
			descriptionNode.attributedText = attributedText.attributedSubstring(from: range)
		}
	}
	
	func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
		guard let attributedText = editableTextNode.attributedText else {
			FirebaseService.updateUserAbout(with: "")
			return
		}
		FirebaseService.updateUserAbout(with: attributedText.string)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		descriptionNode.style.height = ASDimension(unit: .points, value: 240)
		
		// vertical stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.spacing = 10
		verticalStack.children = [titleTextNode, descriptionNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: 17.5, left: 15, bottom: 17.5, right: 20)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: verticalStack)
		
		return textInsetSpec
	}
	
}
