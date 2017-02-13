//
//  LoginScreen.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 18/7/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import UIKit
import CoreMedia
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import CoreGraphics

class BALoginController: UIViewController, FBSDKLoginButtonDelegate {
	
	let repeatVideo = UIRepeatingVideo()
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = ColorPalette.white
		self.automaticallyAdjustsScrollViewInsets = false
		
		navigationController?.isNavigationBarHidden = true
		
		initializeInterface()
	}
	
	func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Swift.Error!) {
		
		if (error != nil){
			
		} else if (result.isCancelled){
			
		} else {
			
			let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
			
			FIRAuth.auth()?.signIn(with: credential) { (user, error) in
				if let error = error {
					print("Sign in failed:", error.localizedDescription)
				} else {
					// should wait until this finishes
					FirebaseService.registerUser(user!).then(execute: { _ -> Void in
						self.moveToCreateUserScreen()
					}).catch(execute: { _ in })
				}
			}
			
		}
	}
	
	func initializeInterface(){
		
		view.addSubview(repeatVideo.playerViewController.view)
		
		NotificationCenter.default.addObserver(self, selector: #selector(rewindVideo(_:)),
		                                       name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
		                                       object: repeatVideo.playerViewController.player?.currentItem)
		
		// ios status bar height is 20px
		let logoView : UIImageView = UIImageView(frame: CGRect(x: 0, y: 20, width: 300, height: 300))
		
		logoView.center = CGPoint(x: ez.screenWidth / 2, y: ez.screenHeight / 2 - 40)
		logoView.contentMode = .scaleAspectFit
		logoView.image = UIImage(named: "splash_logo")
		view.addSubview(logoView)
		
		let fbbutton = FBSDKLoginButton()
		fbbutton.frame = CGRect(x: 40, y: logoView.frame.maxY - 30, width: ez.screenWidth - 80, height: 50)
		fbbutton.readPermissions = ["public_profile", "user_friends", "user_birthday"]
		fbbutton.publishPermissions = ["rsvp_event"]
		fbbutton.delegate = self
		
		let warningView = UITextView()
		warningView.frame = CGRect(x: 5, y: (fbbutton.frame).maxY + 5, width: ez.screenWidth - 10, height: 0)
		warningView.font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightLight)
		warningView.textColor = ColorPalette.white
		warningView.text = "By continuing, you agree to our Terms of Service\nand Privacy Policy"
		warningView.textAlignment = .center
		warningView.isScrollEnabled = false
		warningView.isEditable = false
		warningView.isSelectable = false
		warningView.backgroundColor = UIColor.clear
		
		let size = warningView.sizeThatFits(warningView.frame.size)
		warningView.frame.setNewFrameHeight(size.height)
		
		view.addSubview(fbbutton)
		view.addSubview(warningView)
	}

	func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
		return true
	}
	
	func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
		try! FIRAuth.auth()!.signOut()
	}
	
	@objc func rewindVideo(_ notification: Notification) {
		let zeroCM = CMTime(seconds: 0, preferredTimescale: 1000000000)
		repeatVideo.playerLayer.player?.seek(to: zeroCM)
	}
	
	func moveToCreateUserScreen() {
		// pushes
		let createUserScreen = BAEditProfileController(with: FirebaseService.currentUserId, as: .create)
		navigationController?.pushViewController(createUserScreen, animated: true)
	}
}
