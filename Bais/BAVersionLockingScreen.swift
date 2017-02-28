//
//  BAVersionLockingScreen.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 28/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class BAVersionLockingScreen: ASViewController<ASDisplayNode>{
	
	init (){
		let node = BAVersionLockingScreenCellNode()
		super.init(node: node)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func applicationWillEnterForeground(_ notification: NSNotification) {
		let topController = self.navigationController?.topViewController!
		if (!(topController is UIAlertController)){
			self.presentAlertController()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		presentAlertController()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		NotificationCenter.default.addObserver(self,
		                                       selector:#selector(applicationWillEnterForeground(_:)),
		                                       name:NSNotification.Name.UIApplicationWillEnterForeground,
		                                       object: nil)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
	}
	
	func presentAlertController(){
		let alertController = UIAlertController(title: "An update is required", message: "In order to keep using the app, Bais needs be updated.", preferredStyle: .actionSheet)
		
		let alertAction = UIAlertAction(title: "Go to AppStore", style: .default) { action in
			AppsCommunicator.openAppStore()
		}
		
		alertController.addAction(alertAction)
		present(alertController, animated: true, completion: nil)
	}
}
