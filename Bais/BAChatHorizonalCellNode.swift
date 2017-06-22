//
//  BAChatHorizonalCellNode.swift
//  BAIS
//
//  Created by jbursztyn on 6/19/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BAChatHorizonalCellNode: ASCellNode {
    
    var session: Session!
    var sessionNode = ASNetworkImageNode()
    
    required init(with session: Session) {
        super.init()
        
        selectionStyle = .none
        
        self.session = session
        
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
        
        sessionNode.setURL(URL(string: otherUser.profilePicture), resetToDefault: false)
        sessionNode.shouldRenderProgressImages = true
        sessionNode.contentMode = .scaleAspectFill
        sessionNode.imageModificationBlock = { image in
            var modifiedImage: UIImage!
            let rect = CGRect(origin: CGPoint(0, 0), size: image.size)
            
            UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
            let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 80, height: 80))
            maskPath.addClip()
            image.draw(in: rect)
            modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return modifiedImage
        }
        
        self.addSubnode(sessionNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imagePlace = ASRatioLayoutSpec(ratio: 1, child: sessionNode)
        imagePlace.style.preferredSize = CGSize(width: 80, height: 80)
        return ASInsetLayoutSpec (insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 5), child: imagePlace)
    }
}