//
//  BAEventController.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 7/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//
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

final class BAEventController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, UIGestureRecognizerDelegate, BAMapCellNodeDelegate {
	
	// change this to one user array _usersToDisplay with two pointer arrays _friends and _requests
	var event = Event()
	var backButtonNode = ASButtonNode()
	
	var tableNode: ASTableNode {
		return node as! ASTableNode
	}
	
	init(with event: Event) {
		super.init(node: ASTableNode())
		self.event = event

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
		
		backButtonNode.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
		backButtonNode.setImage(UIImage(named: "back-button"), for: [])
		backButtonNode.addTarget(self, action: #selector(backButtonPressed(_:)), forControlEvents: .touchUpInside)
		super.node.addSubnode(backButtonNode)
	}
	
	func backButtonPressed(_ sender: UIButton){
		_ = self.navigationController?.popViewController(animated: true)
	}
	
	func editButtonPressed(_ sender: UIButton){
		// TODO: implement edit screen
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.navigationController!.interactivePopGestureRecognizer!.isEnabled = true
		self.navigationController!.interactivePopGestureRecognizer!.delegate =  self
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		if (scrollView.contentOffset.y < 0){
			scrollView.contentOffset.y = 0
		}
		
		backButtonNode.view.center = CGPoint(x: backButtonNode.view.center.x,
		                                     y: scrollView.contentOffset.y + backButtonNode.view.frame.height / 2)
		
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	//MARK: - BAMapCellNode delegate methods
	
	internal func mapCellNodeDidClickUberButton(_ mapViewCell: BAMapCellNode) {
		
	}
	
	internal func mapCellNodeDidClickDirectionsButton(_ mapViewCell: BAMapCellNode) {
		
	}
	
	//MARK: - ASTableNode data source and delegate.
	
	func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		let item = indexPath.item
		
		if (item == 0){
			let headerCellNode = BAImageCarouselCellNode(with: event)
			return headerCellNode
		} else if (item == 1){
			let basicCellNode = BABasicEventInfoCellNode(with: event)
			return basicCellNode
		} else if (item == 2 && event.place.isValid()){
			let mapCellNode = BAMapCellNode(with: event.place)
			mapCellNode.delegate = self
			return mapCellNode
		} else if (item == 3){
			let descriptionCellNode = BADescriptionInfoCellNode(with: event)
			return descriptionCellNode
		}
		
		return BASpacerCellNode()
	}
	
	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return 5
	}
	
}
