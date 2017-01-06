//
//  ASLikeButton.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 24/8/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop

class BALikeButton : ASButtonNode{
    
    var tapped : Bool = false;
    let likeButton : ASImageNode = ASImageNode();
    let likeLabel : ASTextNode = ASTextNode();
    var likeValue : Int = 0;
    
    let nameAttributes = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
        NSForegroundColorAttributeName: UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1)]
    
	init (likeCount : Int){
		
        super.init();
		
		likeValue = likeCount;
		
        super.frame = CGRect(x: 0, y: 0, width: 100, height: 40);
        
        likeButton.frame = CGRect(x: 15, y: 11, width: 14, height: 14);
        likeButton.contentMode = .scaleAspectFit;
        likeButton.image = UIImage(named: "empty_like");
        
        likeLabel.frame = CGRect(x: likeButton.frame.maxX + 7, y: 10, width: 65, height: 20);
        likeLabel.attributedText = NSAttributedString(string:String(likeValue) + " likes", attributes: nameAttributes);
        
        self.addTarget(self, action: #selector(buttonPressed(sender:)), forControlEvents: .touchUpInside);
        
        self.addSubnode(likeButton);
        self.addSubnode(likeLabel);
    }
    
    func buttonPressed(sender: UIButton) {
		
		let spring = POPSpringAnimation(propertyNamed: kPOPViewScaleXY);
		spring?.velocity = NSValue(cgPoint: CGPoint(x: 5, y: 5));
		spring?.springBounciness = 20;
		self.likeButton.pop_add(spring, forKey: "sendAnimation");
		
        let likeFilename : String;
		
        if (tapped){
            likeFilename = "empty_like";
            likeValue -= 1;
        }else{
            likeFilename = "full_like";
            likeValue += 1;
        }
        
        likeButton.image = UIImage(named: likeFilename);
        likeLabel.attributedString = NSAttributedString(string:String(likeValue) + " likes", attributes: nameAttributes);
        
        tapped = !tapped;
    }
    
}
