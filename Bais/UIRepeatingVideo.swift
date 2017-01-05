//
//  UIRepeatVideo.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 1/8/16.
//  Copyright © 2016 Claxon. All rights reserved.
//


import Foundation
import AVKit
import AVFoundation
import Foundation
import CoreMedia
import CoreGraphics

class UIRepeatingVideo{
    
    var playerViewController : AVPlayerViewController = AVPlayerViewController();
    var playerLayer : AVPlayerLayer = AVPlayerLayer();
    
    // starts the loginscreen video by default, on fullscreen
    convenience init (){
        let filePath : String = Bundle.main.path(forResource: "rollercoaster_comp", ofType: "mp4")!;
        let movieURL : URL = URL(fileURLWithPath: filePath);
        
        // if it's running on iPhone 4 or 4s, then remove black borders
        if (ez.screenHeight == 480 && ez.screenWidth == 320){
            self.init(frame: CGRect(x:-30, y:0, width: ez.screenWidth * 1.3, height: ez.screenHeight * 1.3), nsurl: movieURL);
        }else{
            self.init(frame: CGRect(x:0, y:0, width: ez.screenWidth, height: ez.screenHeight), nsurl: movieURL);
        }
    }
    
    init (frame : CGRect, nsurl : URL){
		
        let playerAsset = AVAsset(url: nsurl);
        let playerItem = AVPlayerItem(asset: playerAsset);
        
        let player : AVPlayer = AVPlayer(playerItem: playerItem);
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none;
        
        playerLayer = AVPlayerLayer(player: player);
        playerLayer.frame = frame;
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        playerLayer.player?.play();
        playerLayer.player?.isMuted = true;
        let audioSession = AVAudioSession.sharedInstance();
        try! audioSession.setCategory(AVAudioSessionCategoryAmbient,
                                      with: AVAudioSessionCategoryOptions.mixWithOthers);
        
        playerViewController.view.layer.addSublayer(playerLayer);
        playerViewController.view.frame = frame;
        playerViewController.showsPlaybackControls = false;
	}
	
    func unloadVideo(){
        //removeObserver();
        playerViewController.player?.pause();
        playerViewController.player?.replaceCurrentItem(with: nil);
    }
	
	/*
    func removeObserver(){
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime);
    }
	*/
}
