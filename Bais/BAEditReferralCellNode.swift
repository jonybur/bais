//
//  BAEditReferralCellNode.swift
//  BAIS
//
//  Created by jonathan.bursztyn on 7/29/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class BAEditReferralCellNode: ASCellNode, ASEditableTextNodeDelegate {
    let titleTextNode = ASTextNode()
    let descriptionNode = ASEditableTextNode()
    let buttonNode = ASButtonNode()
    let titleAttributes = [
        NSFontAttributeName: UIFont.init(name: "Nunito-SemiBold", size: 14),
        NSForegroundColorAttributeName: ColorPalette.grey]
    
    override init() {
        super.init()
        
        let paragraphAttributes = NSMutableParagraphStyle()
        paragraphAttributes.lineSpacing = 5
        
        descriptionNode.typingAttributes = [
            NSFontAttributeName: UIFont.init(name: "Nunito-Regular", size: 16),
            NSForegroundColorAttributeName: ColorPalette.grey,
            NSParagraphStyleAttributeName: paragraphAttributes]
        
        titleTextNode.attributedText = NSAttributedString(string: "Promo code", attributes: titleAttributes)
        
        descriptionNode.attributedPlaceholderText = NSAttributedString(string: "Optional",
                                                                       attributes: [
                                                                        NSFontAttributeName: UIFont.init(name: "Nunito-Regular", size: 16),
                                                                        NSForegroundColorAttributeName: ColorPalette.lightGrey,
                                                                        NSParagraphStyleAttributeName: paragraphAttributes])
        descriptionNode.attributedText = NSAttributedString(string: "", attributes: descriptionNode.typingAttributes)
        descriptionNode.delegate = self
        descriptionNode.returnKeyType = .done
        descriptionNode.maximumLinesToDisplay = 1
        descriptionNode.scrollEnabled = false
        descriptionNode.autocapitalizationType = .allCharacters
        
        addSubnode(titleTextNode)
        addSubnode(descriptionNode)
        addSubnode(buttonNode)
    }
    
    func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
        guard let attributedText = editableTextNode.attributedText else { return }
        let enterIndex = attributedText.string.indexOfCharacter("\n")
        if (enterIndex != nil){
            var newText = attributedText.string
            let index = newText.index(newText.startIndex, offsetBy: enterIndex!)
            newText.remove(at: index)
            descriptionNode.attributedText = NSAttributedString(string: newText,
                                                                attributes: descriptionNode.typingAttributes)
            descriptionNode.resignFirstResponder()
        }
        if (attributedText.length > 10){
            let range = NSRange(location: 0, length: 10)
            descriptionNode.attributedText = attributedText.attributedSubstring(from: range)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        descriptionNode.style.height = ASDimension(unit: .points, value: 24)
        
        let spacerSpec = ASLayoutSpec()
        spacerSpec.style.flexGrow = 1.0
        spacerSpec.style.flexShrink = 1.0
        
        // horizontal stack
        let horizontalStack = ASStackLayoutSpec.horizontal()
        horizontalStack.alignItems = .center // center items vertically in horiz stack
        horizontalStack.justifyContent = .start // justify content to left
        horizontalStack.style.flexShrink = 1.0
        horizontalStack.style.flexGrow = 1.0
        horizontalStack.children = [titleTextNode, spacerSpec]
        
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

