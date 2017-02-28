//
//  BALoadingController.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 27/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Crashlytics

class BALoadingController: UIViewController{

	init (){
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white
		
		// maybe add a loading here?
		FirebaseService.getCurrentUser().then { user -> Void in
			// You can call any combination of these three methods
			Crashlytics.sharedInstance().setUserName(user.fullName)
			Crashlytics.sharedInstance().setUserIdentifier(user.id)
			
			// load interface after getting user
			// this allows us to check wether user has location, etc.
			if (user.country == ""){
				// if user does not have nationality set up (this resolves closing the app before finishing registation bug)
				let createUserScreen = BAEditProfileController(with: user, as: .create)
				self.navigationController?.pushViewController(createUserScreen, animated: true)
			} else {
				let tabBarController = BATabBarController()
				self.navigationController?.pushViewController(tabBarController, animated: false)
			}
			
		}.catch { _ in }
	}
	
}
