//
//  BAChatHorizontalScrollCellNode.swift
//  BAIS
//
//  Created by jbursztyn on 6/19/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BAChatHorizontalScrollCellNode: ASCellNode {
    
    var sessions: [Session]!
    var sessionNodes = [ASNetworkImageNode]()
    
    // TODO: ADD A ASCOLLECTIONNODE HERE
    
    required init(with sessions: [Session]) {
        super.init()
        
        selectionStyle = .none
        
        self.sessions = sessions
        
        for session in sessions{
            
            let imageNode = ASNetworkImageNode()
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
            
            sessionNodes.append(imageNode)
            self.addSubnode(imageNode)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var ratios = [ASRatioLayoutSpec]()
        for sessionNode in sessionNodes{
            // imagen
            let imagePlace = ASRatioLayoutSpec(ratio: 1, child: sessionNode)
            imagePlace.style.maxWidth = ASDimension(unit: .points, value: 60)
            ratios.append(imagePlace)
        }
        
        // horizontal stack
        let horizontalStack = ASStackLayoutSpec()
        horizontalStack.alignItems = .center
        horizontalStack.direction = .horizontal
        horizontalStack.style.flexShrink = 1.0
        horizontalStack.style.flexGrow = 1.0
        horizontalStack.children = ratios
        
        return ASInsetLayoutSpec (insets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10), child: horizontalStack)
    }
}
