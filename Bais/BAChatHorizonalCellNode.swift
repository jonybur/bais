//
//  BAChatHorizonalCellNode.swift
//  BAIS
//
//  Created by jbursztyn on 6/19/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

enum ChatHorizonalCellNodeMode: String{
    case leftMost = "leftMost", center = "center", rightMost = "rightMost"
}

class BAChatHorizonalCellNode: ASCellNode {
    
    var session: Session!
    var sessionNode = ASNetworkImageNode()
    let nameNode = ASTextNode()
    var mode: ChatHorizonalCellNodeMode!
    
    required init(with session: Session, mode: ChatHorizonalCellNodeMode) {
        super.init()
        
        self.mode = mode
        
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
            let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 75, height: 75))
            maskPath.addClip()
            image.draw(in: rect)
            modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return modifiedImage
        }
        
        
        let nameAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium),
            NSForegroundColorAttributeName: ColorPalette.grey]
        
        nameNode.attributedText = NSAttributedString(string: otherUser.firstName, attributes: nameAttributes)
        
        addSubnode(sessionNode)
        addSubnode(nameNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let imagePlace = ASRatioLayoutSpec(ratio: 1, child: sessionNode)
        imagePlace.style.preferredSize = CGSize(width: 75, height: 75)
        
        // vertical stack
        let verticalStack = ASStackLayoutSpec()
        verticalStack.direction = .vertical
        verticalStack.alignItems = .center
        verticalStack.children = [imagePlace, nameNode]
        verticalStack.spacing = 5
        
        var edgeInsets = UIEdgeInsets()
        if (mode == .center){
            edgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 5, right: 4)
        } else if (mode == .leftMost){
            edgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 5, right: 0)
        } else if (mode == .rightMost){
            edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 15)
        }
        
        return ASInsetLayoutSpec(insets: edgeInsets, child: verticalStack)
    }
}
