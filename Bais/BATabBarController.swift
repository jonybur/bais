//
//  BouncesStyleTabBarController.swift
//  ESTabBarControllerExample
//
//  Created by lihao on 16/5/21.
//  Copyright © 2016年 Egg Swift. All rights reserved.
//

import UIKit
import ESTabBarController
import AwaitKit
import CoreLocation
import FBSDKLoginKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import Hero

open class BATabBarController: ESTabBarController, CLLocationManagerDelegate, HeroViewControllerDelegate {
	
	let locationManager = CLLocationManager()
	
    open override func viewDidLoad() {
		
		super.viewDidLoad()
		
		automaticallyAdjustsScrollViewInsets = false
		
		isHeroEnabled = true
		self.title = ""
		self.tabBar.shadowImage = UIImage(named: "transparent")
		self.tabBar.backgroundImage = UIImage(named: "transparent")
		self.tabBar.isTranslucent = true
		self.tabBar.alpha = 0.9
		//self.tabBar.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.6)
		
		self.navigationController?.setNavigationBarHidden(true, animated: false)
		
		setBATabBarController()
		
		locationManager.delegate = self
		let authorizationStatus = CLLocationManager.authorizationStatus()
		switch(authorizationStatus){
		
		case .authorizedWhenInUse:
			locationManager.requestLocation()
			break
	
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
			break
			
		case .denied:
			print ("Location services are denied")
			break
			
		case .restricted:
			print ("Location services are restricted")
			break
			
		default:
			break
		}
	}
	
	private func setBATabBarController(){
		let v1 = BAUsersController()
		let v2 = BAFriendsController()
		let v3 = BACalendarController()
		let v4 = BAProfileController(with: FirebaseService.currentUserId)
		
		v1.tabBarItem   = ESTabBarItem.init(content: ESTabBarItemContent.init(animator: IrregularityStyleAnimator.init()))
		v2.tabBarItem   = ESTabBarItem.init(content: ESTabBarItemContent.init(animator: IrregularityBasicStyleAnimator.init()))
		v3.tabBarItem   = ESTabBarItem.init(content: ESTabBarItemContent.init(animator: IrregularityBasicStyleAnimator.init()))
		v4.tabBarItem   = ESTabBarItem.init(content: ESTabBarItemContent.init(animator: IrregularityBasicStyleAnimator.init()))
		
		v1.tabBarItem.image = UIImage.init(named: "home-empty-icon")
		v2.tabBarItem.image = UIImage.init(named: "chat-icon")
		v3.tabBarItem.image = UIImage.init(named: "calendar-icon")
		v4.tabBarItem.image = UIImage.init(named: "settings-icon")
		
		let controllers = [v1, v2, v3, v4]
		self.viewControllers = controllers
		
		self.selectedIndex = 0
	}
	
	open override func viewDidAppear(_ animated: Bool) {
		self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		self.navigationController?.setNavigationBarHidden(true, animated: true)
		UIApplication.shared.statusBarStyle = .default
		guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
		statusBar.backgroundColor = ColorPalette.white
	}
	
	public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		let authorizationStatus = CLLocationManager.authorizationStatus();

		if (authorizationStatus == .authorizedWhenInUse){
			locationManager.requestLocation();
		}
	}
	
	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
		// with this if we make sure that location has coordinates
		if let location = locationManager.location?.coordinate {
			FirebaseService.updateUserLocation(location);
		}
	}
		
	public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
		print("Location Manager failed with error");
	}
}
