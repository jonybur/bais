//
//  BALicensesHeaderCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 1/3/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol BALicensesHeaderNodeDelegate: class {
	func licensesHeaderNodeDidClickBackButton()
}

class BALicensesHeaderCellNode: ASCellNode{

	let backButtonNode = ASButtonNode()
	let titleNode = ASTextNode()
	weak var delegate: BALicensesHeaderNodeDelegate?
	
	required override init() {
		super.init()
		
		backButtonNode.setImage(UIImage(named:"chat-back"), for: [])
		backButtonNode.addTarget(self, action: #selector(editPressed(_:)), forControlEvents: .touchUpInside)
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		titleNode.attributedText = NSAttributedString(string: "Licenses", attributes: nameAttributes)
		
		addSubnode(backButtonNode)
		addSubnode(titleNode)
	}
	
	func editPressed(_ sender: UIButton){
		delegate?.licensesHeaderNodeDidClickBackButton()
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		backButtonNode.style.preferredSize = CGSize(width: 50, height: 50)
		backButtonNode.style.layoutPosition = CGPoint(x: 0, y: 10)
		
		let absoluteSpec = ASAbsoluteLayoutSpec(children: [backButtonNode])
		
		let insets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
		
		let buttonSpec = ASInsetLayoutSpec(insets: insets, child: absoluteSpec)
		let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: titleNode)
		
		return ASOverlayLayoutSpec(child: centerSpec, overlay: buttonSpec)
	}
	
}
