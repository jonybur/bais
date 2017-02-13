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

final class BASettingsController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate,
BASettingsHeaderNodeDelegate, BASettingsOptionsNodeDelegate, UIGestureRecognizerDelegate {
	
	// change this to one user array _usersToDisplay with two pointer arrays _friends and _requests
	var user = User()
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
		
		FirebaseService.getCurrentUser().then { user -> Void in
			self.user = user
		}.catch { _ in }
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		userObserver = FirebaseService.usersReference.child(user.id)
		
		userObserver?.observe(.value, with: { snapshot in
			let user = User(fromSnapshot: snapshot)
			self.user = user
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
			let headerCellNode = BASettingsHeaderCellNode(with: user)
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
		print("stop")
	}
	func settingsOptionsNodeDidClickPrivacyPolicyButton(){
		print("stop")
	}
	func settingsOptionsNodeDidClickTermsOfServiceButton(){
		print("stop")
	}
	func settingsOptionsNodeDidClickLicensesButton(){
		print("stop")
	}
	func settingsOptionsNodeDidClickLogoutButton(){
		print("stop")
	}
	func settingsOptionsNodeDidClickDeleteAccountButton(){
		print("stop")
	}
	
	//MARK: - BASettingsHeaderNodeDelegate methods
	
	func settingsHeaderNodeDidClickEditButton(){
		let editProfileController = BAEditProfileController(with: user, as: .settings)
		navigationController?.pushViewController(editProfileController, animated: true)
	}
	
	//MARK: - Dealloc
	
	override func viewWillDisappear(_ animated: Bool) {
		userObserver?.removeAllObservers()
	}
	
}
