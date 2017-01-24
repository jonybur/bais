//
//  BATableCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 19/1/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol BAUsersHeaderCellNodeDelegate: class {
	func usersHeaderCellNodeDidClickButton(_ usersViewCell: BAUsersHeaderCellNode);
}

// add a delegate here to be able switch around
class BAUsersHeaderCellNode: ASCellNode {
	
	let nameNode = ASTextNode()
	let buttonNode = ASButtonNode()
	weak var delegate: BAUsersHeaderCellNodeDelegate?
	var currentMode: UsersDisplayMode = .distance
	
	enum UsersDisplayMode : String{
		case distance = "distance", country = "country"
		
		func next() -> UsersDisplayMode {
			switch self {
			case .distance:
				return .country;
			default:
				return .distance;
			}
		}
	}
	
	override init() {
		super.init()
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		nameNode.attributedText = NSAttributedString(string: "Sorted by Distance", attributes: nameAttributes)
		buttonNode.setImage(UIImage(named:"country-button"), for: [])
		
		self.selectionStyle = .none
		
		addSubnode(self.nameNode)
		addSubnode(self.buttonNode)
		
		buttonNode.addTarget(self, action: #selector(self.buttonPressed(_:)), forControlEvents: .touchUpInside)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		buttonNode.style.preferredSize = CGSize(width: 50, height: 50)
		buttonNode.style.flexShrink = 1.0

		let spacerSpec = ASLayoutSpec()
		spacerSpec.style.flexGrow = 1.0
		spacerSpec.style.flexShrink = 1.0
		
		// horizontal stack
		let horizontalStack = ASStackLayoutSpec.horizontal()
		horizontalStack.alignItems = .center
		horizontalStack.justifyContent = .start
		horizontalStack.style.flexShrink = 1.0
		horizontalStack.style.flexGrow = 1.0
		horizontalStack.children = [nameNode, spacerSpec, buttonNode]
		
		// move down
		let insetSpec = ASInsetLayoutSpec()
		insetSpec.insets = UIEdgeInsets(top: 20, left: 2.5, bottom: 0, right: 2.5)
		insetSpec.child = horizontalStack

		return insetSpec
	}
	
	//MARK: - BAUsersHeaderCellNodeDelegate methods
	func buttonPressed(_ sender: UIButton){
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		switch (currentMode) {
		case .distance:
			nameNode.attributedText = NSAttributedString(string: "Only Argentina", attributes: nameAttributes)
			buttonNode.setImage(UIImage(named:"country-button"), for: [])
			break
		case .country:
			nameNode.attributedText = NSAttributedString(string: "Sorted by Distance", attributes: nameAttributes)
			buttonNode.setImage(UIImage(named:"distance-button"), for: [])
			break
		}
		
		currentMode = currentMode.next()
		
		delegate?.usersHeaderCellNodeDidClickButton(self);
	}
}
