//
//  BASettingsCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 9/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BASettingsOptionsCellNode: ASCellNode{
	
	let contactUsNode = BASettingsHeaderElementCellNode(title: "Contact Us")
	let helpAndSupportNode = BASettingsButtonElementCellNode(title: "Help & Support")
	let aboutBaisNode = BASettingsButtonElementCellNode(title: "About the NGO")

	let spacerNode = BASettingsSpacerElementCellNode()
	let shareBaisNode = BASettingsButtonElementCellNode(title: "Share Bais")
	let spacerNode2 = BASettingsSpacerElementCellNode()
	
	let legalNode = BASettingsHeaderElementCellNode(title: "Legal")
	let privacyPolicyNode = BASettingsButtonElementCellNode(title: "Privacy Policy")
	let termsServiceNode = BASettingsButtonElementCellNode(title: "Terms of Service")
	let licensesNode = BASettingsButtonElementCellNode(title: "Licenses")
	
	let spacerNode3 = BASettingsSpacerElementCellNode()
	let logoutNode = BASettingsButtonElementCellNode(title: "Logout")
	let spacerNode4 = BASettingsSpacerElementCellNode()

	let deleteAccountNode = BASettingsButtonElementCellNode(title: "Delete Account")
	let spacerNode5 = BASettingsSpacerElementCellNode()
	
	required override init() {
		super.init()
		addSubnode(contactUsNode)
		addSubnode(helpAndSupportNode)
		addSubnode(aboutBaisNode)
		addSubnode(shareBaisNode)
		addSubnode(legalNode)
		addSubnode(privacyPolicyNode)
		addSubnode(termsServiceNode)
		addSubnode(licensesNode)
		addSubnode(logoutNode)
		addSubnode(deleteAccountNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .start
		verticalStack.children = [contactUsNode, helpAndSupportNode, aboutBaisNode, spacerNode, shareBaisNode, spacerNode2,
		                          legalNode, privacyPolicyNode, termsServiceNode, licensesNode, spacerNode3,
		                          logoutNode, spacerNode4, deleteAccountNode, spacerNode5]
		return verticalStack
	}
}
