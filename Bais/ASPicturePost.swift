//
//  ASPicturePost.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 6/8/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ASPicturePost : ASWallPost{
    
    let imageNode : ASNetworkImageNode = ASNetworkImageNode();
	
	init (yPosition : CGFloat, picture : InstagramPicture){
		
		super.init(yPosition: yPosition, media: picture);
		
        imageNode.frame = CGRect(x:0, y: self.frame.height, width: self.frame.width, height: self.frame.width);
        imageNode.setURL(URL(string: picture.imageUrl), resetToDefault: false);
        imageNode.shouldRenderProgressImages = true;
		
        self.addSubnode(imageNode);
		self.frame.setNewFrameHeight(imageNode.frame.height);
		
		super.createDivisionLine();
		super.createLowerButtons();
		super.createCaptionBox();
		
		imageNode.measure(imageNode.frame.size);
    }
}
