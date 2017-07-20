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
        
        imageNode.setURL(URL(string: "https://firebasestorage.googleapis.com/v0/b/bais-79d67.appspot.com/o/000coupons%2Ffreeshot_buda.png?alt=media&token=84ae14c8-02ed-47a2-b0de-1b1a7f4bd5cf"), resetToDefault: false)
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
        // imagen
        let imageLayout = ASRatioLayoutSpec(ratio: 1, child: imageNode)
        imageLayout.style.minWidth = ASDimension(unit: .points, value: constrainedSize.max.width)
        return imageLayout
    }
}

