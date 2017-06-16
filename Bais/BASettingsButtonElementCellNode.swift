//
//  BASettingsButtonElementCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 9/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BASettingsButtonElementCellNode: ASButtonNode{
	
	let titleTextNode = ASTextNode()
    let notificationCountNode = ASImageNode()
    let notificationCountTextNode = ASTextNode()
    var notificationCount = 0
	
    convenience init(title: String) {
        self.init(title: title, notificationCount: 0);
    }
    
    required init(title: String, notificationCount: Int) {
        super.init()
        
        self.notificationCount = notificationCount
        
        notificationCountNode.image = UIImage(named: "empty-circle")
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		titleTextNode.attributedText = NSAttributedString(string: title, attributes: nameAttributes)
        
        if (notificationCount > 0){
            let notificationCountAttributes = [
                NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
                NSForegroundColorAttributeName: UIColor.white]
            let unreadCount = String(notificationCount)
            notificationCountTextNode.attributedText = NSAttributedString(string: unreadCount, attributes: notificationCountAttributes)
        }
				
        addSubnode(titleTextNode)
        addSubnode(notificationCountNode)
        addSubnode(notificationCountTextNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// text inset
		let textInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: titleTextNode)
        
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
        if (notificationCount > 0){
            let unreadCount = String(notificationCount)
            if(unreadCount.characters.count == 1){
                notificationCountTextNode.style.layoutPosition = CGPoint(x: 8, y: 4)
            } else if(unreadCount.characters.count == 2){
                notificationCountTextNode.style.layoutPosition = CGPoint(x: 4, y: 4)
            }
            
            let notificationCountLayout = ASAbsoluteLayoutSpec(sizing: .sizeToFit, children: [notificationCountNode, notificationCountTextNode])
            let notificationInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 17.5)
            let notificationInsetsSpec = ASInsetLayoutSpec(insets: notificationInsets, child: notificationCountLayout)
            
            horizontalStack.children = [textInsetSpec, spacerSpec, notificationInsetsSpec]
        }else{
            horizontalStack.children = [textInsetSpec]
        }

        let centerSpec = ASStackLayoutSpec()
        centerSpec.child = horizontalStack
        centerSpec.style.width = ASDimension(unit: .points, value: constrainedSize.max.width)
        
        return centerSpec
	}
}
