//
//  BAEditCountryPickerCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 12/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import CountryPicker

protocol BAEditCountryPickerCellNodeDelegate: class {
	func editCountryPickerNodeDidClosePicker(country: String, code: String)
}

class BAEditCountryPickerCellNode: ASCellNode, CountryPickerDelegate {
	weak var delegate: BAEditCountryPickerCellNodeDelegate?
	let doneButtonNode = ASButtonNode()
	var countryName: String?
	var countryCode: String?
	
	required override init() {
		super.init()
		
		DispatchQueue.main.async(execute: {
			self.view.frame = CGRect(x: 0, y: 0, width: ez.screenWidth, height: 220)
			let countryPicker = CountryPicker(frame: CGRect(x: 0, y: 0, width: ez.screenWidth, height: 180))
			countryPicker.delegate = self
			self.view.addSubview(countryPicker)
		})
		
		doneButtonNode.setTitle("Done",
		                        with: UIFont.init(name: "SourceSansPro-SemiBold", size: 14),
		                        with: ColorPalette.grey, for: [])
		
		doneButtonNode.addTarget(self, action: #selector(doneButtonPressed(_:)), forControlEvents: .touchUpInside)
		
		addSubnode(doneButtonNode)
	}
	
	internal func countryPicker(_ picker: CountryPicker!, didSelectCountryWithName name: String!, code: String!){
		countryName = name
		countryCode = code
	}
	
	func doneButtonPressed(_ sender: UIButton){
		guard let name = countryName, let code = countryCode else { return }
		
		frame = CGRect(x: 0, y: 0, width: ez.screenWidth, height: 0)
		delegate?.editCountryPickerNodeDidClosePicker(country: name, code: code)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// left button
		doneButtonNode.style.preferredSize = CGSize(width: constrainedSize.max.width - 30, height: 50)
		doneButtonNode.contentVerticalAlignment = .center
		doneButtonNode.contentHorizontalAlignment = .middle
		
		// text inset
		let textInsets = UIEdgeInsets(top: 180, left: 15, bottom: 20, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: doneButtonNode)
		
		return textInsetSpec
	}
}
