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
	var presentingNoLocationController = false
	
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
		
		self.setBATabBarController()
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
	
	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		navigationController?.setNavigationBarHidden(true, animated: true)
		UIApplication.shared.statusBarStyle = .default
		guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
		statusBar.backgroundColor = ColorPalette.white
		
		NotificationCenter.default.addObserver(self,
		                                       selector:#selector(applicationWillEnterForeground(_:)),
		                                       name:NSNotification.Name.UIApplicationWillEnterForeground,
		                                       object: nil)
	}

	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}
	
	func observeFriendBadge(){
	
		var invitedFriendsCount = 0
		var unreadSessionsCount = 0
		
		FirebaseService.usersReference.child(FirebaseService.currentUserId).child("friends").observe(.value, with: { snapshot in
			guard let tabBarItem = self.viewControllers?[1].tabBarItem as? ESTabBarItem else { return }
			guard let snapshotValue = snapshot.value as? NSDictionary else { return }
			invitedFriendsCount = 0
			for (_, user) in snapshotValue{
				guard let userDictionary = user as? NSDictionary else { continue }
				guard let relationshipStatus = userDictionary["status"] as? String else { continue }
				guard let relationshipPostedBy = userDictionary["posted_by"] as? String else { continue }
				if (relationshipStatus == "invited" && relationshipPostedBy != FirebaseService.currentUserId){
					// invitation received
					invitedFriendsCount += 1
				}
			}
			if (invitedFriendsCount + unreadSessionsCount <= 0){
				tabBarItem.badgeValue = nil
			} else {
				let totalCount = invitedFriendsCount + unreadSessionsCount
				tabBarItem.badgeValue = String(totalCount)
			}
		})
		
		// this is A unread messages
		FirebaseService.usersReference.child(FirebaseService.currentUserId).child("sessions").observe(.value, with: { snapshot in
			guard let sessionsValue = snapshot.value as? NSDictionary else { return }
			guard let tabBarItem = self.viewControllers?[1].tabBarItem as? ESTabBarItem else { return }
			unreadSessionsCount = 0
			for (_, attributes) in sessionsValue{
				guard let sessionAttributes = attributes as? NSDictionary else { continue }
				guard let isSessionActive = sessionAttributes["active"] as? Bool else { continue }
				guard let sessionUnreadCount = sessionAttributes["unread_count"] as? Int else { continue }
				unreadSessionsCount += sessionUnreadCount > 0 ? 1 : 0
				if (isSessionActive){
					if (invitedFriendsCount + unreadSessionsCount <= 0){
						tabBarItem.badgeValue = nil
					} else {
						let totalCount = invitedFriendsCount + unreadSessionsCount
						tabBarItem.badgeValue = String(totalCount)
					}
				}
			}
			
		})
	}
	
	public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		let authorizationStatus = CLLocationManager.authorizationStatus()
		if (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways){
			locationManager.requestLocation()
			if (presentingNoLocationController){
				dismissNoLocationController()
				presentingNoLocationController = false
			}
		} else if (authorizationStatus == .denied){
			presentingNoLocationController = true
			let noLocationController = BALocationLockingScreen()
			present(noLocationController, animated: true, completion: nil)
		}
	}
	
	func dismissNoLocationController(){
		let topController = navigationController?.topViewController!
		if (topController is UIAlertController){
			navigationController?.dismiss(animated: true, completion: { 
				self.dismiss(animated: true, completion: nil)
			})
		} else {
			dismiss(animated: true, completion: nil)
		}
	}
	
	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
		// with this if we make sure that location has coordinates
		if let location = locationManager.location?.coordinate {
			FirebaseService.updateUserLocation(location)
		}
	}
		
	public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
		print("Location Manager failed with error")
	}
	
	func applicationWillEnterForeground(_ notification: NSNotification) {
		FirebaseService.resetBadgeCount()
		
		FirebaseService.checkVersionUpdate().then { updateIsRequired -> Void in
			if (updateIsRequired){
				let versionLockingController = BAVersionLockingScreen()
				self.navigationController?.present(versionLockingController, animated: true, completion: nil)
			}
		}.catch { _ in }
	}
}
