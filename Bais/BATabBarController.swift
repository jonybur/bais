//
//  BouncesStyleTabBarController.swift
//  ESTabBarControllerExample
//
//  Created by lihao on 16/5/21.
//  Copyright © 2016年 Egg Swift. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import CoreLocation
import FBSDKLoginKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import Crashlytics

open class BATabBarController: ESTabBarController, CLLocationManagerDelegate {
	
	let locationManager = CLLocationManager()
	
    open override func viewDidLoad() {
		super.viewDidLoad()
		
		automaticallyAdjustsScrollViewInsets = false
		
		title = ""
		tabBar.shadowImage = UIImage(named: "transparent")
		tabBar.backgroundImage = UIImage(named: "transparent")
		tabBar.isTranslucent = true
		tabBar.alpha = 0.9
		view.backgroundColor = ColorPalette.white
		
		navigationController?.setNavigationBarHidden(true, animated: false)

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
		
		FirebaseService.updateUserNotificationToken()
		FirebaseService.resetBadgeCount()
		
		// maybe add a loading here?
		FirebaseService.getCurrentUser().then { user -> Void in
			// You can call any combination of these three methods
			Crashlytics.sharedInstance().setUserName(user.fullName)
			Crashlytics.sharedInstance().setUserIdentifier(user.id)
			
			// load interface after getting user
			// this allows us to check wether user has location, etc.
			if (user.country != ""){
				self.setBATabBarController()
			} else {
				// if user does not have nationality set up (this resolves closing the app before finishing registation bug)
				let createUserScreen = BAEditProfileController(with: user, as: .create)
				self.navigationController?.pushViewController(createUserScreen, animated: true)
			}
			
		}.catch { _ in }
		
		NotificationCenter.default.addObserver(self,
		                                       selector:#selector(applicationWillEnterForeground(_:)),
		                                       name:NSNotification.Name.UIApplicationWillEnterForeground,
		                                       object: nil)
	}
	
	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}
	
	private func setBATabBarController(){
		let v1 = BAUsersController()
		let v2 = BAFriendsController()
		let v3 = BACalendarController()
		let v4 = BASettingsController()
		
		tabBar.backgroundColor = ColorPalette.white
		
		v1.tabBarItem = ESTabBarItem.init(BAHomeContentView(), title: nil, image: UIImage(named: "home-empty-icon"), selectedImage: UIImage(named: "home-full-icon"))
		v2.tabBarItem = ESTabBarItem.init(BABouncesContentView(), title: nil, image: UIImage(named: "chat-icon"), selectedImage: UIImage(named: "chat-icon"))
		v3.tabBarItem = ESTabBarItem.init(BABouncesContentView(), title: nil, image: UIImage(named: "calendar-icon"), selectedImage: UIImage(named: "calendar-icon"))
		v4.tabBarItem = ESTabBarItem.init(BABouncesContentView(), title: nil, image: UIImage(named: "settings-icon"), selectedImage: UIImage(named: "settings-icon"))
		
		let controllers = [v1, v2, v3, v4]
		viewControllers = controllers
		
		observeFriendBadge()
		
		selectedIndex = 0
	}
	
	func observeFriendBadge(){
		
		/*
		A = mensajes recibidos (sin leer)
		B = friend requests (invites) recibidas
		A + B = badge count
		
		A sumar users/user_id/sessions/session_id/unread_count de cada active session del usuario
		B entrar a child "friends" y sumar todos los que son inviteRecieved
		*/
		
		// this is A unread messages
		FirebaseService.usersReference.child(FirebaseService.currentUserId).child("sessions").observe(.value, with: { snapshot in
			guard let sessionsValue = snapshot.value as? NSDictionary else { return }
			guard let tabBarItem = self.viewControllers?[1].tabBarItem as? ESTabBarItem else { return }
			var unreadCount = 0

			for (_, attributes) in sessionsValue{
				guard let sessionAttributes = attributes as? NSDictionary else { continue }
				guard let isSessionActive = sessionAttributes["active"] as? Bool else { continue }
				guard let sessionUnreadCount = sessionAttributes["unread_count"] as? Int else { continue }
				unreadCount += sessionUnreadCount
				if (isSessionActive){
					if (unreadCount <= 0){
						tabBarItem.badgeValue = nil
					} else {
						tabBarItem.badgeValue = String(unreadCount)
					}
				}
			}
			
		})
	}
	
	open override func viewDidAppear(_ animated: Bool) {
		navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		navigationController?.setNavigationBarHidden(true, animated: true)
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
	
	func applicationWillEnterForeground(_ notification: NSNotification) {
		FirebaseService.resetBadgeCount()
	}
}
