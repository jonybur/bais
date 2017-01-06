//
//  ASPicturePost.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 6/8/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BAVideoPost : BAWallPost{
	
	let videoNode : ASVideoNode = ASVideoNode();
	
	init (yPosition : CGFloat, video : InstagramVideo){
		
		super.init(yPosition: yPosition, media: video);
		
		videoNode.frame = CGRect(x:0, y: self.frame.height, width: self.frame.width, height: self.frame.width);
		let asset = AVAsset(url: URL(string: video.videoUrl)!);
		videoNode.asset = asset;
		videoNode.shouldAutoplay = true;
		videoNode.shouldAutorepeat = true;
		videoNode.muted = true;
		
		self.addSubnode(videoNode);
		self.frame.setNewFrameHeight(videoNode.frame.height);
		
		super.createDivisionLine();
		super.createLowerButtons();
		super.createCaptionBox();
	}
}
