//
//  BASettingsController.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 8/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase
import PromiseKit
import FBSDKLoginKit

final class BASettingsController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate,
BASettingsHeaderNodeDelegate, BASettingsOptionsNodeDelegate, UIGestureRecognizerDelegate {
	
	// change this to one user array _usersToDisplay with two pointer arrays _friends and _requests
	var userObserver: FIRDatabaseReference?
	
	var tableNode: ASTableNode {
		return node as! ASTableNode
	}
	
	init() {
		super.init(node: ASTableNode())
		
		tableNode.delegate = self
		tableNode.dataSource = self
		tableNode.view.separatorStyle = .none
		tableNode.allowsSelection = false
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("Storyboards are not supported")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		userObserver = FirebaseService.usersReference.child(FirebaseService.currentUserId)
		
		userObserver?.observe(.value, with: { snapshot in
			let user = User(from: snapshot)
			CurrentUser.user = user
			self.tableNode.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .fade)
		})
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        
		navigationController!.interactivePopGestureRecognizer!.isEnabled = true
		navigationController!.interactivePopGestureRecognizer!.delegate =  self
	}
	
//MARK: - ASTableNode data source and delegate.
	
	func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		let item = indexPath.item
		
		if (item == 0){
			let headerCellNode = BASettingsHeaderCellNode(with: CurrentUser.user)
			headerCellNode.delegate = self
			return headerCellNode
		} else if (item == 1){
			let settingsCellNode = BASettingsOptionsCellNode()
			settingsCellNode.delegate = self
			return settingsCellNode
		}
		
		return BASpacerCellNode()
	}
	
	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
//MARK: - BASettingsOptionsNodeDelegate methods
	
	func settingsOptionsNodeDidClickShareButton(){
		// text to share
		let text = "Check out BAIS... it shows you exchange students nearby! http://apple.co/2lTS4Ru"
		
		// set up activity view controller
		let textToShare = [ text ]
		let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
		
		// exclude some activity types from the list (optional)
		activityViewController.excludedActivityTypes = [ UIActivityType.airDrop ]
		
		// present the view controller
		present(activityViewController, animated: true, completion: nil)
	}
	
	func settingsOptionsNodeDidClickFeedbackButton() {
		let alert = UIAlertController(title: "Give Us Feedback", message: "Your suggestions and ideas are important to us.", preferredStyle: .alert)
		alert.addTextField { textField in
			textField.placeholder = "Write your suggestions"
			textField.autocapitalizationType = .sentences
		}
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { action in
			let textField = alert.textFields![0] as UITextField
			if ((textField.text?.characters.count)! > 0){
				FirebaseService.sendFeedback(textField.text!)
				self.showThankYou()
			}
		}))
		present(alert, animated:true, completion:nil)
	}
	
	func showThankYou(){
		let alert = UIAlertController(title: "Thank you! ❤️", message: "Though we can't respond to everyone who submits feedback, we review many of the ideas people send us and use them to improve the BAIS experience for everyone.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
		present(alert, animated:true, completion:nil)
	}
	
	func settingsOptionsNodeDidClickPrivacyPolicyButton(){
		AppsCommunicator.openWebsite("http://bursz.com/legal/bais_privacy_policy.pdf")
	}
	func settingsOptionsNodeDidClickTermsOfServiceButton(){
		AppsCommunicator.openWebsite("http://bursz.com/legal/bais_terms_of_use.pdf")
	}
	func settingsOptionsNodeDidClickLicensesButton(){
		let licensesController = BALicensesController()
		navigationController?.pushViewController(licensesController, animated: true)
	}
	func settingsOptionsNodeDidClickLogoutButton(){
		let alert = UIAlertController(title: nil, message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { action in
			FirebaseService.logOut()
			FBSDKLoginManager().logOut()
			let loginController = BALoginController()
			self.navigationController?.pushViewController(loginController, animated: true)
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	func settingsOptionsNodeDidClickDeleteAccountButton(){
		print("stop")
	}
	
//MARK: - BASettingsHeaderNodeDelegate methods
	
	func settingsHeaderNodeDidClickEditButton(){
		let editProfileController = BAEditProfileController(with: CurrentUser.user, as: .settings)
		navigationController?.pushViewController(editProfileController, animated: true)
	}
	
//MARK: - Dealloc
	
	override func viewWillDisappear(_ animated: Bool) {
		userObserver?.removeAllObservers()
	}
}
