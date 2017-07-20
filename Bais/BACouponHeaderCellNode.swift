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
    
    required override init() {
        super.init()
        
        let nameAttributes = [
            NSFontAttributeName: UIFont.init(name: "SourceSansPro-Bold", size: 28),
            NSForegroundColorAttributeName: ColorPalette.grey]
        
        nameNode.attributedText = NSAttributedString(string: "My Coupons", attributes: nameAttributes)
        
        self.selectionStyle = .none
        
        self.addSubnode(self.nameNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        // move down
        let insetSpec = ASInsetLayoutSpec()
        insetSpec.insets = UIEdgeInsets(top: 28, left: 3, bottom: 30, right: 15)
        insetSpec.child = nameNode
        
        return insetSpec
    }
}
