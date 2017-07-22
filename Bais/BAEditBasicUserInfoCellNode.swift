//
//  BAEditBasicUserInfoCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 10/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

protocol BAEditBasicUserInfoCellNodeDelegate: class {
	func editBasicUserInfoCellNodeDidPressOpenCountryPicker()
}

class BAEditBasicUserInfoCellNode: ASCellNode {
	let nameAndAgeNode = ASTextNode()
	let nationalityNode = ASTextNode()
	let openCountryPickerButtonNode = ASButtonNode()
	weak var delegate: BAEditBasicUserInfoCellNodeDelegate?
	var countryEditing = false
	
	required init(with user: User, allowsCountryEditing: Bool) {
		super.init()
		
		countryEditing = allowsCountryEditing
		
		let nameAndAgeAttributes = [
			NSFontAttributeName: UIFont.init(name: "Nunito-Bold", size: 24),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		var nameAndAgeString = user.firstName
		if (user.age > 0){
			nameAndAgeString += ", " + String(user.age)
		}
		nameAndAgeNode.attributedText = NSAttributedString(string: nameAndAgeString, attributes: nameAndAgeAttributes)

		let distanceAttributes = [
			NSFontAttributeName: UIFont.init(name: "Nunito-SemiBold", size: 16),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		var nationalityText = ""
		if (user.countryCode.characters.count > 0 && user.countryCode != ""){
			nationalityText = user.country
		} else if (allowsCountryEditing) {
			nationalityText = "Where are you from?"
		}
		nationalityNode.attributedText = NSAttributedString(string: nationalityText, attributes: distanceAttributes)
		
		nationalityNode.maximumNumberOfLines = 1
		
		openCountryPickerButtonNode.setImage(UIImage(named: "plus"), for: [])
		openCountryPickerButtonNode.addTarget(self, action: #selector(openCountryPickerButtonPressed(_:)), forControlEvents: .touchUpInside)
		
		addSubnode(openCountryPickerButtonNode)
		addSubnode(nameAndAgeNode)
		addSubnode(nationalityNode)
	}
	
	func openCountryPickerButtonPressed(_ sender: UIButton){
		delegate?.editBasicUserInfoCellNodeDidPressOpenCountryPicker()
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// opencountrypicker button
		openCountryPickerButtonNode.style.preferredSize = CGSize(width: 50, height: 50)
		
		// vertical stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .start
		verticalStack.justifyContent = .spaceBetween
		verticalStack.spacing = 6
		
		if (countryEditing){
			// horizontal stack
			let horizontalStack = ASStackLayoutSpec()
			horizontalStack.direction = .horizontal
			horizontalStack.spacing = 10
			horizontalStack.alignItems = .center
			horizontalStack.children = [nationalityNode, openCountryPickerButtonNode]
			
			verticalStack.children = [nameAndAgeNode, horizontalStack]
		} else {
			verticalStack.children = [nameAndAgeNode, nationalityNode]
		}
		
		// text inset
		let textInsets = UIEdgeInsets(top: 17.5, left: 15, bottom: 17.5, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: verticalStack)
		
		return textInsetSpec
	}
	
}
