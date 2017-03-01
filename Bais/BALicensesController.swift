//
//  BALicensesController.swift
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

final class BALicensesController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate,
BADefaultHeaderCellNodeDelegate, BALicensesNodeDelegate, UIGestureRecognizerDelegate {

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
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		navigationController!.interactivePopGestureRecognizer!.isEnabled = true
		navigationController!.interactivePopGestureRecognizer!.delegate =  self
	}
	
//MARK: - Settings node
	
	internal func licensesNodeDidClickLicenseButton(_ button: BALicensesButtonElementCellNode) {
		let licenseDetailController = BALicenseDetailController(productName: button.productName, license: button.license)
		navigationController?.pushViewController(licenseDetailController, animated: true)
	}
	
	internal func defaultHeaderNodeDidClickBackButton() {
		_ = navigationController?.popViewController(animated: true)
	}
	
//MARK: - ASTableNode data source and delegate.
	
	func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		let item = indexPath.item
		
		if (item == 0){
			let headerCellNode = BADefaultHeaderCellNode(title: "Licenses")
			headerCellNode.delegate = self
			return headerCellNode
		} else if (item == 1){
			let settingsCellNode = BALicensesCellNode()
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
	
//MARK: - BASettingsHeaderNodeDelegate methods
	
	func licensesHeaderNodeDidClickBackButton(){
		_ = navigationController?.popViewController(animated: true)
	}
	
}
