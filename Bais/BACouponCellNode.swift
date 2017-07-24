//
//  BACouponCellNode.swift
//  BAIS
//
//  Created by jonathan.bursztyn on 7/19/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import FirebaseDatabase
import Firebase

class BACouponCellNode: ASCellNode {
    
    let imageNode = ASNetworkImageNode()
    weak var delegate: BACalendarCellNodeDelegate?
    
    required init(with coupon: Coupon) {
        super.init()
        
        selectionStyle = .none
        imageNode.setURL(URL(string: coupon.imageUrl), resetToDefault: false)
        imageNode.shouldRenderProgressImages = true
        imageNode.contentMode = .scaleAspectFill
        imageNode.imageModificationBlock = { image in
            var modifiedImage: UIImage!
            let rect = CGRect(origin: CGPoint(0, 0), size: image.size)
            UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
            let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10))
            maskPath.addClip()
            image.draw(in: rect)
            modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return modifiedImage
        }
        
        imageNode.clipsToBounds = true;
        addSubnode(imageNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        // image is expected to be 960x430
        let imageLayout = ASRatioLayoutSpec(ratio: 0.448, child: imageNode)
        // top left bottom right
        let insetLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(12, 12, 12, 12), child: imageLayout)
        return insetLayout
    }
}

