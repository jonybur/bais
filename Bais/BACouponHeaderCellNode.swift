//
//  BACouponHeaderCellNode.swift
//  BAIS
//
//  Created by jonathan.bursztyn on 7/19/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop

// add a delegate here to be able switch modes
class BACouponHeaderCellNode: ASCellNode {
    
    let nameNode = ASTextNode()
    let subtitleNode = ASTextNode()
    
    required override init() {
        super.init()
        
        let nameAttributes = [
            NSFontAttributeName: UIFont.init(name: "Nunito-Bold", size: 28),
            NSForegroundColorAttributeName: ColorPalette.grey]
        let subtitleAttributes = [
            NSFontAttributeName: UIFont.init(name: "Nunito-SemiBold", size: 18),
            NSForegroundColorAttributeName: ColorPalette.grey]
        
        nameNode.attributedText = NSAttributedString(string: "My Coupons",
                                                     attributes: nameAttributes)
        subtitleNode.attributedText = NSAttributedString(string: "Your Invite Code Is " + CurrentUser.user.referenceId,
                                                         attributes: subtitleAttributes)
        
        selectionStyle = .none
        addSubnode(nameNode)
        addSubnode(subtitleNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        // vertical stack
        let verticalStack = ASStackLayoutSpec()
        verticalStack.alignItems = .start
        verticalStack.direction = .vertical
        verticalStack.spacing = 5
        verticalStack.children = [nameNode, subtitleNode]
        
        // move down
        let insetSpec = ASInsetLayoutSpec()
        insetSpec.insets = UIEdgeInsets(top: 45, left: 15, bottom: 15, right: 15)
        insetSpec.child = verticalStack
        
        return insetSpec
    }
}
