//
//  BAChatVerticalHeaderCellNode.swift
//  BAIS
//
//  Created by jbursztyn on 6/25/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

// add a delegate here to be able switch modes
class BAChatVerticalHeaderCellNode: ASCellNode {
    let nameNode = ASTextNode()
    
    required override init() {
        super.init()
        
        let nameAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold),
            NSForegroundColorAttributeName: ColorPalette.orange]
        
        nameNode.attributedText = NSAttributedString(string: "Messages", attributes: nameAttributes)
        
        self.selectionStyle = .none
        
        self.addSubnode(self.nameNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        // move down
        let insetSpec = ASInsetLayoutSpec()
        insetSpec.insets = UIEdgeInsets(top: 0, left: 15, bottom: 10, right: 0)
        insetSpec.child = nameNode
        
        return insetSpec
    }
}
