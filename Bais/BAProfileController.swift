//
//  BATableController.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 18/1/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase
import PromiseKit
import Hero

final class BAProfileController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, UIGestureRecognizerDelegate {
	
	// change this to one user array _usersToDisplay with two pointer arrays _friends and _requests
	var user = User()
	
	var tableNode: ASTableNode {
		return node as! ASTableNode
	}
	
	init(with userId: String){
		super.init(node: ASTableNode())
		
		FirebaseService.getUser(with: userId).then { user -> Void in
			self.user = user
			self.commonInit()
		}.catch { _ in }
	}
	
	init(with user: User) {
		super.init(node: ASTableNode())
		self.user = user
		commonInit()
	}
	
	func commonInit(){
		isHeroEnabled = true
		tableNode.delegate = self
		tableNode.dataSource = self
		tableNode.view.separatorStyle = .singleLine
		tableNode.allowsSelection = false
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("Storyboards are not supported")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.navigationController!.interactivePopGestureRecognizer!.isEnabled = true
		self.navigationController!.interactivePopGestureRecognizer!.delegate =  self
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
//MARK: - ASTableNode data source and delegate.
	
	func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		let item = indexPath.item
		
		if (item == 0){
			let headerCellNode = BAImageCarouselCellNode(with: user)
			return headerCellNode
		} else if (item == 1){
			let basicCellNode = BABasicInfoCellNode(with: user)
			return basicCellNode
		} else if (item == 2){
			let descriptionCellNode = BADescriptionInfoCellNode(with: user)
			return descriptionCellNode
		}
		
		let chatNode = BAChatCellNode(with: user)
		return chatNode
	}
	
	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	
}
