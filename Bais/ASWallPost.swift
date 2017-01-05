//
//  ASWallPost.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 6/8/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import AwaitKit

// base class for all wall posts, contains header and lower buttons
class ASWallPost : ASDisplayNode{
	
	var instagramMedia : InstagramMedia = InstagramMedia();
    
	init (yPosition : CGFloat, media : InstagramMedia){
        super.init();
        
        let xPosition : CGFloat = 10;
        let cardWidth : CGFloat = (ez.screenWidth) - xPosition * 2;
		instagramMedia = media;
		
        self.frame = CGRect(x: xPosition, y: yPosition, width: cardWidth, height: 0);
        self.backgroundColor = UIColor.white;
		
        //createHeader();
        
        // self.view isn't a node, so we can only use it on the main thread
		self.layer.cornerRadius = 10;
		self.view.clipsToBounds = true;
    }
    
	func createHeader(){
        let nameAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
            NSForegroundColorAttributeName: UIColor.black]
        
        let dateAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular),
            NSForegroundColorAttributeName: UIColor(red: 0.3451, green: 0.3451, blue: 0.3451, alpha: 1.0)]
        
        let profilePicture : ASNetworkImageNode = ASNetworkImageNode();
        profilePicture.setURL(URL(string: instagramMedia.user.profilePicture), resetToDefault: false);
        profilePicture.shouldRenderProgressImages = true;
        profilePicture.frame = CGRect(x:10,y:10,width:40,height:40);
        async {
            profilePicture.view.layer.cornerRadius = 10;
        }
        
        let nameNode : ASTextNode = ASTextNode();
        nameNode.frame = CGRect(x:70, y:15, width:self.frame.width - 70, height:20);
        nameNode.attributedText = NSAttributedString(string: instagramMedia.user.userName, attributes:nameAttributes);
        
        let dateNode : ASTextNode = ASTextNode();
        dateNode.frame = CGRect(x:70, y:nameNode.frame.maxY, width:self.frame.width - 70, height:20);
		let dateFormatter = DateFormatter();
		dateFormatter.dateFormat = "EEEE d 'at' h:mm a";
		let dateString = dateFormatter.string(from: instagramMedia.creationDate as Date);
        dateNode.attributedText = NSAttributedString(string:dateString, attributes:dateAttributes);
        
        self.addSubnode(profilePicture);
        self.addSubnode(nameNode);
        self.addSubnode(dateNode);
        
        self.frame.setNewFrameHeight(profilePicture.frame.maxY + 10);
    }
	
	func createDivisionLine(){
	
		let line : ASImageNode = ASImageNode();
		line.frame = CGRect(15, self.frame.height + 20, self.frame.width - 30, 1);
		line.backgroundColor = UIColor.black;
		line.alpha = 0.08;
		
		self.addSubnode(line);
		
		self.frame.setNewFrameHeight(self.frame.height + line.frame.height + 25)
	}
	
	func createLowerButtons(){
		let likeButton : ASLikeButton = ASLikeButton(likeCount: instagramMedia.likes);
		likeButton.position = CGPoint(x: likeButton.frame.width / 2, y: self.frame.height + 15);
		
		self.addSubnode(likeButton);
		
		self.frame.setNewFrameHeight(self.frame.height + 20);
	}
	
	func createCaptionBox(){
		
		let captionAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
			NSForegroundColorAttributeName: UIColor.black]
		
		let dateAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 10, weight: UIFontWeightLight),
			NSForegroundColorAttributeName: UIColor.black]
		
		/*
		let captionBox : UITextView = UITextView();
		captionBox.attributedText = NSAttributedString(string: instagramMedia.caption, attributes: captionAttributes);
		captionBox.frame = CGRect(x: 10, y: self.frame.height + 10, w: self.frame.width - 20, h: 100);
		captionBox.dataDetectorTypes = .All;
		captionBox.scrollEnabled = false;
		captionBox.editable = false;
		let newSize = captionBox.sizeThatFits(captionBox.frame.size);
		captionBox.size = newSize;
		*/
		
		let captionBox : ASTextNode = ASTextNode();
		captionBox.frame = CGRect(0, 0, self.frame.width - 20, 100);
		captionBox.attributedText = NSAttributedString(string: instagramMedia.caption, attributes: captionAttributes);
		captionBox.frame = CGRect(10, self.frame.height + 10,
		                          self.frame.width - 20,
		                          captionBox.frame(forTextRange: NSRange(location: 0, length: String(instagramMedia.caption).characters.count)).height);
		
		let dateBox : ASTextNode = ASTextNode();
		dateBox.frame = CGRect(10, captionBox.frame.maxY + 10, self.frame.width - 20, 12);
		dateBox.attributedText = NSAttributedString(string: instagramMedia.creationDate.timeAgoSinceDate(true).uppercased(), attributes: dateAttributes);
		dateBox.alpha = 0.5;
		
		//self.view.addSubview(captionBox);
		self.addSubnode(captionBox)
		self.addSubnode(dateBox);
		
		self.frame.setNewFrameHeight(dateBox.frame.maxY + 13);
	}
	
}
