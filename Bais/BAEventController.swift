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

final class BAEventController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, UIGestureRecognizerDelegate, BAMapCellNodeDelegate, WebServiceDelegate {
	
	// change this to one user array _usersToDisplay with two pointer arrays _friends and _requests
	var event = Event()
	var backButtonNode = ASButtonNode()
	let webService = WebService()
	
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
		
		webService.delegate = self
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
		_ = self.navigationController?.popViewController(animated: true)
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
		                                     y: scrollView.contentOffset.y + backButtonNode.view.frame.height / 2 + 10)
		
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	//MARK: - WebService delegate methods
	
	internal func uberProductsLoaded(_ uberProducts: [UberProduct]) {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		for product in uberProducts{
			alert.addAction(UIAlertAction(title: product.displayName, style: .default, handler: { action in
				AppsCommunicator.openUber(product.productId, dropoff: self.event.place.coordinates.coordinate)
			}))
		}
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		present(alert, animated: true, completion: nil)
	}
	
	
	//MARK: - BAMapCellNode delegate methods

	internal func mapCellNodeDidClickUberButton(_ mapViewCell: BAMapCellNode) {
		if (AppsCommunicator.canOpenUber()){
			webService.getUberProducts(event.place.coordinates.coordinate)
			return
		}
		
		let alert = UIAlertController(title: "Uber Not Installed",
		                              message: "To use this function please install Uber",
		                              preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK",
		                              style: .cancel,
		                              handler: nil))
		
		present(alert, animated: true, completion: nil)
	}
	
	internal func mapCellNodeDidClickDirectionsButton(_ mapViewCell: BAMapCellNode) {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let canOpenWaze = AppsCommunicator.canOpenWaze()
		let canOpenGoogleMaps = AppsCommunicator.canOpenGoogleMaps()
		let locationCoordinate = event.place.coordinates.coordinate
		
		if (canOpenWaze || canOpenGoogleMaps){
			if (canOpenGoogleMaps){
				alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { action in
					AppsCommunicator.openGoogleMaps(locationCoordinate)
				}))
			}
			alert.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { action in
				AppsCommunicator.openAppleMaps(locationCoordinate)
			}))
			if (canOpenWaze){
				alert.addAction(UIAlertAction(title: "Waze Maps", style: .default, handler: { action in
					AppsCommunicator.openWaze(locationCoordinate)
				}))
			}
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			present(alert, animated: true, completion: nil)
		} else {
			AppsCommunicator.openAppleMaps(locationCoordinate)
		}
	}
	
	//MARK: - ASTableNode data source and delegate
	
	func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		let item = indexPath.item
		
		if (item == 0){
			let headerCellNode = BAImageCarouselCellNode(with: event)
			return headerCellNode
		} else if (item == 1){
			let basicCellNode = BABasicEventInfoCellNode(with: event)
			return basicCellNode
		}
		
		if (event.place.isValid()){
			if (item == 2){
				let mapCellNode = BAMapCellNode(with: event.place)
				mapCellNode.delegate = self
				return mapCellNode
			} else if (item == 3){
				let descriptionCellNode = BADescriptionInfoCellNode(with: event)
				return descriptionCellNode
			}
		} else{
			if (item == 2){
				let descriptionCellNode = BADescriptionInfoCellNode(with: event)
				return descriptionCellNode
			}
		}
		
		return BASpacerCellNode()
	}
	
	func numberOfSections(in tableNode: ASTableNode) -> Int {
		return 1
	}
	
	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return event.place.isValid() ? 5 : 4
	}
	
}
