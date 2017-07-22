//
//  BABasicUserInfoCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 4/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

protocol BABasicUserInfoCellNodeDelegate: class{
	func basicUserInfoTapMore(_ basicUserInfoCellNode: BABasicUserInfoCellNode)
}

class BABasicUserInfoCellNode: ASCellNode {
	
	let nameAndAgeNode = ASTextNode()
	let distanceNode = ASTextNode()
	let nationalityNode = ASTextNode()
	let moreButtonNode = ASButtonNode()
	weak var delegate: BABasicUserInfoCellNodeDelegate?
	
	required init(with user: User) {
		super.init()
		
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
		
		var distanceString = ""
		if ((CurrentUser.location) != nil){
			distanceString = user.location.distance(from: CurrentUser.location!).redacted()
		}
		
		distanceNode.attributedText = NSAttributedString(string: distanceString, attributes: distanceAttributes)
		distanceNode.maximumNumberOfLines = 1
		
		nationalityNode.attributedText = NSAttributedString(string: user.country, attributes: distanceAttributes)
		nationalityNode.maximumNumberOfLines = 1
		
		moreButtonNode.setImage(UIImage(named: "more-button"), for: [])
		moreButtonNode.addTarget(self, action: #selector(self.moreButtonPressed(_:)), forControlEvents: .touchUpInside)
		
		addSubnode(nameAndAgeNode)
		addSubnode(distanceNode)
		addSubnode(nationalityNode)
		addSubnode(moreButtonNode)
	}
	
	func moreButtonPressed(_ sender: UIButton){
		delegate?.basicUserInfoTapMore(self)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		// vertical stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .start
		verticalStack.justifyContent = .spaceBetween
		verticalStack.spacing = 6
		verticalStack.children = [nameAndAgeNode, nationalityNode, distanceNode]
		
		// more button
		moreButtonNode.style.preferredSize = CGSize(width: 50, height: 50)
		moreButtonNode.style.flexShrink = 1.0
		
		// spacer
		let spacerSpec = ASLayoutSpec()
		spacerSpec.style.flexGrow = 1.0
		spacerSpec.style.flexShrink = 1.0
		
		// horizontal stack
		let horizontalStack = ASStackLayoutSpec.horizontal()
		horizontalStack.alignItems = .start
		horizontalStack.justifyContent = .start
		horizontalStack.style.flexShrink = 1.0
		horizontalStack.style.flexGrow = 1.0
		horizontalStack.children = [verticalStack, spacerSpec, moreButtonNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: 17.5, left: 15, bottom: 17.5, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: horizontalStack)
		
		return textInsetSpec
	}
	
}
