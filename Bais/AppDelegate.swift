 //
//  AppDelegate.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 10/7/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import AwaitKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let facebookAppId = "819066684896381"
    let facebookDisplayName = "Bais"
    
    var navigationController = UINavigationController()
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		// Override point for customization after application launch.
		
		Fabric.with([Crashlytics.self])
		
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        FBSDKSettings.setAppID(facebookAppId)
        FBSDKSettings.displayName()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

		// [START register_for_notifications]
		if #available(iOS 10.0, *) {
			let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
			UNUserNotificationCenter.current().requestAuthorization(
				options: authOptions,
				completionHandler: {_, _ in })
			
			// For iOS 10 display notification (sent via APNS)
			UNUserNotificationCenter.current().delegate = self
			// For iOS 10 data message (sent via FCM)
			FIRMessaging.messaging().remoteMessageDelegate = self
			
		} else {
			let settings: UIUserNotificationSettings =
				UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
			application.registerUserNotificationSettings(settings)
		}
		
		application.registerForRemoteNotifications()
		
		// [END register_for_notifications]
		
		FIRApp.configure()
		
		FIRDatabase.database().persistenceEnabled = true
		
		let screen: UIViewController!
		
		if FIRAuth.auth()?.currentUser != nil && FBSDKProfile.current() != nil {
			screen = BATabBarController()
		} else {
			screen = BALoginController()
		}
		
		navigationController.pushViewController(screen, animated: false)
		navigationController.isNavigationBarHidden = true

		window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()
		application.statusBarStyle = .default
		
        return true
    }
	
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        application.statusBarStyle = .lightContent

        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp();
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		//Tricky line
		FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.unknown)
		FirebaseService.updateUserNotificationToken()
	}
		
	// [START receive_message]
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
	                 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		// If you are receiving a notification message while your app is in the background,
		// this callback will not be fired till the user taps on the notification launching the application.
		// TODO: Handle data of notification
		// Print message ID.
		print("Message ID: \(userInfo["gcm.message_id"]!)")
		// Print full message.
		print("%@", userInfo)
	}
	// [END receive_message]
	
	// [START refresh_token]
	func tokenRefreshNotification(_ notification: Notification) {
		if let refreshedToken = FIRInstanceID.instanceID().token() {
			print("InstanceID token: \(refreshedToken)")
		}
		// Connect to FCM since connection may have failed when attempted before having a token.
		connectToFcm()
	}
	// [END refresh_token]
	
	// [START connect_to_fcm]
	func connectToFcm() {
		FIRMessaging.messaging().connect { (error) in
			if error != nil {
				print("Unable to connect with FCM. \(error)")
			} else {
				print("Connected to FCM.")
			}
		}
	}
	// [END connect_to_fcm]
	
	// [START disconnect_from_fcm]
	func applicationDidEnterBackground(_ application: UIApplication) {
		FIRMessaging.messaging().disconnect()
		print("Disconnected from FCM.")
	}
	// [END disconnect_from_fcm]
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
	// Receive displayed notifications for iOS 10 devices.
	func userNotificationCenter(_ center: UNUserNotificationCenter,
	                            willPresent notification: UNNotification,
	                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		let userInfo = notification.request.content.userInfo
		// Print message ID.
		print("Message ID: \(userInfo["gcm.message_id"]!)")
		// Print full message.
		print("%@", userInfo)
	}
}
extension AppDelegate : FIRMessagingDelegate {
	// Receive data message on iOS 10 devices.
	func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
		print("%@", remoteMessage.appData)
	}
}
// [END ios_10_message_handling]

