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

open class ContainerScreen: ESTabBarController, CLLocationManagerDelegate {
	
	let gradientBar : GradientBar = GradientBar();
	let locationManager : CLLocationManager = CLLocationManager();
	
    open override func viewDidLoad() {
		
		super.viewDidLoad();
		
		automaticallyAdjustsScrollViewInsets = false;
				
		self.title = "";
		self.tabBar.shadowImage = UIImage(named: "transparent");
		self.tabBar.backgroundImage = UIImage(named: "background");
		
		self.navigationController?.setNavigationBarHidden(true, animated: false);
		
		setContainerScreen();
		
		locationManager.delegate = self;
		let authorizationStatus = CLLocationManager.authorizationStatus();
		switch(authorizationStatus){
		
		case .authorizedWhenInUse:
			locationManager.requestLocation();
			break;
		
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization();
			break;
			
		case .denied:
			print ("Location services are denied");
			break;
			
		case .restricted:
			print ("Location services are restricted");
			break;
			
		default:
			break;
		}
	}
	
	private func setContainerScreen(){
		let v1 = WallScreen();
		let v2 = CalendarScreen();
		let v3 = BSWaterfallView();//UsersScreen();
		let v4 = FriendsScreen();
		let v5 = SettingsScreen();
		
		v1.tabBarItem   = ESTabBarItem.init(content: ESTabBarItemContent.init(animator: IrregularityBasicStyleAnimator.init()))
		v2.tabBarItem   = ESTabBarItem.init(content: ESTabBarItemContent.init(animator: IrregularityBasicStyleAnimator.init()))
		v3.tabBarItem   = ESTabBarItem.init(content: ESTabBarItemContent.init(animator: IrregularityStyleAnimator.init()))
		v4.tabBarItem   = ESTabBarItem.init(content: ESTabBarItemContent.init(animator: IrregularityBasicStyleAnimator.init()))
		v5.tabBarItem   = ESTabBarItem.init(content: ESTabBarItemContent.init(animator: IrregularityBasicStyleAnimator.init()))
		
		v1.tabBarItem.image = UIImage.init(named: "wall-icon")
		v2.tabBarItem.image = UIImage.init(named: "calendar-icon")
		v3.tabBarItem.image = UIImage.init(named: "home-empty-icon")
		v4.tabBarItem.image = UIImage.init(named: "friends-icon")
		v5.tabBarItem.image = UIImage.init(named: "settings-icon")
		
		let controllers = [v1, v2, v3, v4, v5]
		self.viewControllers = controllers
		
		self.selectedIndex = 2
		
		self.view.addSubview(gradientBar);
	}
	
	open override func viewDidAppear(_ animated: Bool) {
		self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
		self.navigationController?.setNavigationBarHidden(true, animated: true);
		UIApplication.shared.statusBarStyle = .lightContent;
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
			FirebaseAPI.updateUserLocation(location);
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: NSError){
		print("Location Manager failed with error");
	}
}
