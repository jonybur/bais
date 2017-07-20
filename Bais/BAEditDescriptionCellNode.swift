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

protocol BAEditDescriptionCellNodeDelegate: class {
	func editDescriptionCellNodeDidFinishEditing(about: String)
}

class BAEditDescriptionCellNode: ASCellNode, ASEditableTextNodeDelegate {
	weak var delegate: BAEditDescriptionCellNodeDelegate?
	let titleTextNode = ASTextNode()
	let textCounterNode = ASTextNode()
	let descriptionNode = ASEditableTextNode()
	let buttonNode = ASButtonNode()
	let titleAttributes = [
		NSFontAttributeName: UIFont.init(name: "SourceSansPro-Regular", size: 14),
		NSForegroundColorAttributeName: ColorPalette.grey]
	
	required init(with user: User) {
		super.init()

		let paragraphAttributes = NSMutableParagraphStyle()
		paragraphAttributes.lineSpacing = 5
		
		descriptionNode.typingAttributes = [
			NSFontAttributeName: UIFont.init(name: "SourceSansPro-Regular", size: 16),
			NSForegroundColorAttributeName: ColorPalette.grey,
			NSParagraphStyleAttributeName: paragraphAttributes]
		
		titleTextNode.attributedText = NSAttributedString(string: "About you", attributes: titleAttributes)
		
		descriptionNode.attributedPlaceholderText = NSAttributedString(string: "Write about yourself",
		                                                               attributes: [
																		NSFontAttributeName: UIFont.init(name: "SourceSansPro-Regular", size: 16),
																		NSForegroundColorAttributeName: ColorPalette.lightGrey,
																		NSParagraphStyleAttributeName: paragraphAttributes])
		
		descriptionNode.attributedText = NSAttributedString(string: user.about, attributes: descriptionNode.typingAttributes)
		
		textCounterNode.attributedText = NSAttributedString(string: String(user.about.characters.count) + "/400", attributes: titleAttributes)
		
		descriptionNode.delegate = self
		
		addSubnode(titleTextNode)
		addSubnode(textCounterNode)
		addSubnode(descriptionNode)
		addSubnode(buttonNode)
	}
	
	func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
		guard let attributedText = editableTextNode.attributedText else {
			textCounterNode.attributedText = NSAttributedString(string: "0/400", attributes: titleAttributes)
			return
		}
		
		textCounterNode.attributedText = NSAttributedString(string: String(attributedText.length) + "/400", attributes: titleAttributes)
		
		// TODO: re-layout descriptionNode according to attributedText length
		if (attributedText.length > 400){
			let range = NSRange(location: 0, length: 400)
			descriptionNode.attributedText = attributedText.attributedSubstring(from: range)
			textCounterNode.attributedText = NSAttributedString(string: "400/400", attributes: titleAttributes)
		}
	}
	
	func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
		guard let attributedText = editableTextNode.attributedText else {
			delegate?.editDescriptionCellNodeDidFinishEditing(about: "")
			return
		}
		delegate?.editDescriptionCellNodeDidFinishEditing(about: attributedText.string)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		descriptionNode.style.height = ASDimension(unit: .points, value: 240)
		
		let spacerSpec = ASLayoutSpec()
		spacerSpec.style.flexGrow = 1.0
		spacerSpec.style.flexShrink = 1.0
		
		// horizontal stack
		let horizontalStack = ASStackLayoutSpec.horizontal()
		horizontalStack.alignItems = .center // center items vertically in horiz stack
		horizontalStack.justifyContent = .start // justify content to left
		horizontalStack.style.flexShrink = 1.0
		horizontalStack.style.flexGrow = 1.0
		horizontalStack.children = [titleTextNode, spacerSpec, textCounterNode]
		
		// vertical stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.spacing = 10
		verticalStack.children = [horizontalStack, descriptionNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: 17.5, left: 15, bottom: 17.5, right: 20)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: verticalStack)
		
		return textInsetSpec
	}
	
}
