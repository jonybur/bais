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

final class BAProfileController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, UIGestureRecognizerDelegate {
	
	// change this to one user array _usersToDisplay with two pointer arrays _friends and _requests
	var user = User()
	var backButtonNode = ASButtonNode()
	
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

		backButtonNode.frame = CGRect(x: 0, y: 10, width: 75, height: 75)
		backButtonNode.setImage(UIImage(named: "back-button"), for: [])
		backButtonNode.addTarget(self, action: #selector(backButtonPressed(_:)), forControlEvents: .touchUpInside)
		
		super.node.addSubnode(backButtonNode)
	}
	
	func backButtonPressed(_ sender: UIButton){
		_ = navigationController?.popViewController(animated: true)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		navigationController!.interactivePopGestureRecognizer!.isEnabled = true
		navigationController!.interactivePopGestureRecognizer!.delegate =  self
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		if (scrollView.contentOffset.y < 0){
			scrollView.contentOffset.y = 0
		}
		
		backButtonNode.view.center = CGPoint(x: backButtonNode.view.center.x,
		                                     y: scrollView.contentOffset.y + backButtonNode.view.frame.height / 2 + 10)
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
			let basicCellNode = BABasicUserInfoCellNode(with: user)
			return basicCellNode
		} else if (item == 2){
			let descriptionCellNode = BADescriptionInfoCellNode(with: user)
			return descriptionCellNode
		}
		
		return BASpacerCellNode()
	}
	
	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	
}
