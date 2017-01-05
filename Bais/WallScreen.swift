//
//  WallScreen.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 18/7/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import AsyncDisplayKit
import ESTabBarController
import DGActivityIndicatorView
import AwaitKit

class WallScreen : UIViewController{
    
    var scrollNode : ASScrollNode = ASScrollNode();
	
	let activityIndicatorView = DGActivityIndicatorView(type: .ballScale,
	                                                    tintColor: ColorPalette.baisOrange,
	                                                    size: 75);
	
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
        automaticallyAdjustsScrollViewInsets = false;
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.initializeInterface(_:)), name: NSNotification.Name(rawValue: instagramDownloadedKey), object: nil)
        
        view.backgroundColor = ColorPalette.baisBeige;
        
        self.scrollNode.frame = CGRect(x:0, y:0, width: ez.screenWidth, height: ez.screenHeight);
		
		activityIndicatorView!.frame = CGRect(x: (ez.screenWidth - 75) / 2,
		                                      y: (ez.screenHeight - 75) / 2,
		                                      width: 75, height: 75);
		
		self.view.addSubview(activityIndicatorView!);
		activityIndicatorView?.startAnimating();
		
		async{
			CloudController.getInstagramPage();
		}
    }
    
	// gets the notification
	@objc func initializeInterface(_ notification: Notification) {
		
		// TODO: check what can be derived in a secondary thread, there's a reason we're using ASDK here.
		var wallCards : [ASWallPost] = [ASWallPost]();
		var yPosition : CGFloat = GradientBar.height + 10;

		DispatchQueue.main.async(execute: { () -> Void in
			
			for media in FetchedContent.instagramMedia{
				
				var wallPost : ASWallPost;
				
				if (media is InstagramPicture){
					wallPost = ASPicturePost(yPosition: yPosition, picture: media as! InstagramPicture);
				} else if (media is InstagramVideo){
					wallPost = ASVideoPost(yPosition: yPosition, video: media as! InstagramVideo);
				} else {
					wallPost = ASWallPost(yPosition: yPosition, media: InstagramMedia());
				}
			
				yPosition += wallPost.frame.height + 10;
				wallCards.append(wallPost);
				self.scrollNode.addSubnode(wallPost);

			}
			
			self.scrollNode.view.contentSize = CGSize(width: ez.screenWidth, height: wallCards[wallCards.count - 1].frame.maxY + 100);
			
			self.view.addSubview(self.scrollNode.view);
			
			self.activityIndicatorView?.removeFromSuperview();
		})

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
    }
}
