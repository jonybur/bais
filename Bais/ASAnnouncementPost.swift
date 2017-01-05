//
//  ASAnnouncementPost.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 6/8/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ASAnnouncementPost : ASWallPost{
    
    let textNode : ASTextNode = ASTextNode();
    
    init (yPosition : CGFloat){
		super.init(yPosition: yPosition, media: InstagramMedia());
		
        let textAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight),
            NSForegroundColorAttributeName: UIColor.black]
        
        // TODO: add variable height to this
        textNode.frame = CGRect(x:15, y: self.frame.height, width: self.frame.width - 40, height: 30);
        textNode.attributedText = NSAttributedString(string: "Hello World! This is an announcement 🤓", attributes: textAttributes);
        
        self.addSubnode(textNode);
        
        super.createLowerButtons();
    }
    
    /*
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let cellWidth = self.frame.width;
        
        textNode.sizeRange = ASRelativeSizeRangeMake(
            ASRelativeSize(
                width: ASRelativeDimensionMakeWithPercent(0),
                height: ASRelativeDimensionMakeWithPoints(0)),
            ASRelativeSize(
                width: ASRelativeDimensionMakeWithPercent(cellWidth),
                height: ASRelativeDimensionMakeWithPoints(300)))
        textNode.flexGrow = true;
        self.flexGrow = true;
        
        let insetSpecs = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            child: textNode)
        
        return insetSpecs;
    }
    */
}
