//
//  BALocationLockingScreen.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 26/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class BALocationLockingScreen: ASViewController<ASDisplayNode>{

	init (){
		let node = BALocationLockingScreenCellNode()
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
		let alertController = UIAlertController(title: "Where are you?", message: "In order to show you interesting people near you, BAIS needs to know where you are.", preferredStyle: .actionSheet)
		
		let alertAction = UIAlertAction(title: "Open Settings", style: .default) { action in
			AppsCommunicator.openSettings()
		}
		
		alertController.addAction(alertAction)
		present(alertController, animated: true, completion: nil)
	}
}
