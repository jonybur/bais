//
//  BASettingsCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 9/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol BASettingsOptionsNodeDelegate: class {
	func settingsOptionsNodeDidClickShareButton()
	func settingsOptionsNodeDidClickFeedbackButton()
	func settingsOptionsNodeDidClickPrivacyPolicyButton()
	func settingsOptionsNodeDidClickTermsOfServiceButton()
	func settingsOptionsNodeDidClickLicensesButton()
	func settingsOptionsNodeDidClickLogoutButton()
	func settingsOptionsNodeDidClickDeleteAccountButton()
}

class BASettingsOptionsCellNode: ASCellNode{
	
	/*
	let contactUsNode = BASettingsHeaderElementCellNode(title: "Contact Us")
	let helpAndSupportNode = BASettingsButtonElementCellNode(title: "Help & Support")
	let aboutBAISNode = BASettingsButtonElementCellNode(title: "About the NGO")

	let spacerNode = BASettingsSpacerElementCellNode()
	*/
	
    let couponsBAISNode = BASettingsButtonElementCellNode(title: "My Coupons", notificationCount: 1)
	let shareBAISNode = BASettingsButtonElementCellNode(title: "Share BAIS")
	let feedbackNode = BASettingsButtonElementCellNode(title: "Give Us Feedback")
	let spacerNode2 = BASettingsSpacerElementCellNode()
	
	let legalNode = BASettingsHeaderElementCellNode(title: "Legal")
	let privacyPolicyNode = BASettingsButtonElementCellNode(title: "Privacy Policy")
	let termsServiceNode = BASettingsButtonElementCellNode(title: "Terms of Service")
	let licensesNode = BASettingsButtonElementCellNode(title: "Licenses")
	
	let spacerNode3 = BASettingsSpacerElementCellNode()
	let logoutNode = BASettingsButtonElementCellNode(title: "Logout")
	let spacerNode4 = BASettingsSpacerElementCellNode()

	//let deleteAccountNode = BASettingsButtonElementCellNode(title: "Delete Account")
	//let spacerNode5 = BASettingsSpacerElementCellNode()
	
	weak var delegate: BASettingsOptionsNodeDelegate?
	
	required override init() {
		super.init()
		
        couponsBAISNode.addTarget(self, action: #selector(couponsPressed(_:)), forControlEvents: .touchUpInside)
		shareBAISNode.addTarget(self, action: #selector(sharePressed(_:)), forControlEvents: .touchUpInside)
		feedbackNode.addTarget(self, action: #selector(feedbackPressed(_:)), forControlEvents: .touchUpInside)
		privacyPolicyNode.addTarget(self, action: #selector(privacyPolicyPressed(_:)), forControlEvents: .touchUpInside)
		termsServiceNode.addTarget(self, action: #selector(termsOfServicePressed(_:)), forControlEvents: .touchUpInside)
		licensesNode.addTarget(self, action: #selector(licensesPressed(_:)), forControlEvents: .touchUpInside)
		logoutNode.addTarget(self, action: #selector(logoutPressed(_:)), forControlEvents: .touchUpInside)
		//deleteAccountNode.addTarget(self, action: #selector(deleteAccountPressed(_:)), forControlEvents: .touchUpInside)

		/*
		addSubnode(contactUsNode)
		addSubnode(helpAndSupportNode)
		addSubnode(aboutBAISNode)
		*/
		
        addSubnode(couponsBAISNode)
		addSubnode(shareBAISNode)
		addSubnode(feedbackNode)
		addSubnode(legalNode)
		addSubnode(privacyPolicyNode)
		addSubnode(termsServiceNode)
		addSubnode(licensesNode)
		addSubnode(logoutNode)
		//addSubnode(deleteAccountNode)
	}
	
    func couponsPressed(_ sender: UIButton){
        delegate?.settingsOptionsNodeDidClickShareButton()
    }
    
	func sharePressed(_ sender: UIButton){
		delegate?.settingsOptionsNodeDidClickShareButton()
	}
	
	func feedbackPressed(_ sender: UIButton){
		delegate?.settingsOptionsNodeDidClickFeedbackButton()
	}
	
	func privacyPolicyPressed(_ sender: UIButton){
		delegate?.settingsOptionsNodeDidClickPrivacyPolicyButton()
	}
	
	func termsOfServicePressed(_ sender: UIButton){
		delegate?.settingsOptionsNodeDidClickTermsOfServiceButton()
	}
	
	func licensesPressed(_ sender: UIButton){
		delegate?.settingsOptionsNodeDidClickLicensesButton()
	}
	
	func logoutPressed(_ sender: UIButton){
		delegate?.settingsOptionsNodeDidClickLogoutButton()
	}
	
	func deleteAccountPressed(_ sender: UIButton){
		delegate?.settingsOptionsNodeDidClickDeleteAccountButton()
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .start
		verticalStack.children = [/*contactUsNode, helpAndSupportNode, aboutBAISNode, spacerNode,*/couponsBAISNode, shareBAISNode, feedbackNode, spacerNode2, legalNode, privacyPolicyNode, termsServiceNode, licensesNode, spacerNode3, logoutNode, spacerNode4]//, deleteAccountNode, spacerNode5]
		return verticalStack
	}
}
