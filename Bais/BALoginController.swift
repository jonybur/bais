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
import DGActivityIndicatorView

class BALoginController: UIViewController, FBSDKLoginButtonDelegate {
	
	let repeatVideo = UIRepeatingVideo()
    let activityIndicatorView = DGActivityIndicatorView(type: .ballPulse,
                                                        tintColor: ColorPalette.white,
                                                        size: 70)
    var activityIndicatorViewBackground: UIView!
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = ColorPalette.white
		automaticallyAdjustsScrollViewInsets = false
		navigationController?.isNavigationBarHidden = true

        let activityIndicatorSize = (activityIndicatorView?.size)!
        activityIndicatorView!.frame = CGRect(x: (ez.screenWidth - activityIndicatorSize) / 2,
                                              y: (ez.screenHeight - activityIndicatorSize) / 2,
                                              width: activityIndicatorSize, height: activityIndicatorSize)
        
        activityIndicatorViewBackground = UIView()
        activityIndicatorViewBackground.frame = CGRect(x: (ez.screenWidth - 120) / 2,
                                                      y: (ez.screenHeight - 120) / 2,
                                                      width: 120, height: 120)
        activityIndicatorViewBackground.alpha = 0
		let yourCarefullyDrawnPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: activityIndicatorViewBackground.frame.width, height: activityIndicatorViewBackground.frame.height), cornerRadius: 20)
		let maskForYourPath = CAShapeLayer()
		maskForYourPath.path = yourCarefullyDrawnPath.cgPath
		activityIndicatorViewBackground.layer.mask = maskForYourPath
        activityIndicatorViewBackground.backgroundColor = .black

        view.addSubview(repeatVideo.playerViewController.view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(rewindVideo(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: repeatVideo.playerViewController.player?.currentItem)
        
        // ios status bar height is 20px
        let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        
        logoView.center = CGPoint(x: ez.screenWidth / 2, y: ez.screenHeight / 2 - 40)
        logoView.contentMode = .scaleAspectFit
        logoView.image = UIImage(named: "splash_logo")
        view.addSubview(logoView)
        
        let fbbutton = FBSDKLoginButton()
        fbbutton.frame = CGRect(x: 40, y: logoView.frame.maxY - 30, width: ez.screenWidth - 80, height: 50)
        fbbutton.readPermissions = WebService.readPermissions
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
        view.addSubview(activityIndicatorViewBackground)
        view.addSubview(activityIndicatorView!)
    }
	
	func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Swift.Error!) {
		if (error != nil || result.isCancelled){
            self.removeActivityIndicator()
		} else {
			let loginManager = FBSDKLoginManager()
			loginManager.logIn(withPublishPermissions: WebService.publishPermissions, from: self, handler: { (result, error) in
				if (error != nil || (result?.isCancelled)!){ } else {
					self.signInToFirebase()
				}
			})
			
		}
	}
	
	func signInToFirebase(){
		activityIndicatorView?.startAnimating()
		activityIndicatorViewBackground.alpha = 0.75
		
		let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
		FIRAuth.auth()?.signIn(with: credential) { (user, error) in
			if let error = error {
				self.removeActivityIndicator()
				print("Sign in failed:", error.localizedDescription)
			} else {
				// should wait until this finishes
				FirebaseService.registerUser(user!).then(execute: { _ -> Void in
					self.moveToCreateUserScreen()
				}).catch(execute: { _ in })
			}
		}
	}
	
	func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
		return true
	}
	
	func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
		try! FIRAuth.auth()!.signOut()
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	@objc func rewindVideo(_ notification: Notification) {
		let zeroCM = CMTime(seconds: 0, preferredTimescale: 1000000000)
		repeatVideo.playerLayer.player?.seek(to: zeroCM)
	}
    
    func removeActivityIndicator(){
        activityIndicatorView?.stopAnimating()
        activityIndicatorViewBackground.alpha = 0
    }
	
	func moveToCreateUserScreen() {
		// pushes screen
		FirebaseService.getCurrentUser().then { user -> Void in
			let createUserScreen = BAEditProfileController(with: user, as: .create)
			self.navigationController?.pushViewController(createUserScreen, animated: true)
		}.catch { _ in
        }.always { 
            self.removeActivityIndicator()
        }
		
	}
}
