//
//  BALicensesHeaderCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 1/3/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol BADefaultHeaderCellNodeDelegate: class {
	func defaultHeaderNodeDidClickBackButton()
}

class BADefaultHeaderCellNode: ASCellNode{

	let backButtonNode = ASButtonNode()
	let titleNode = ASTextNode()
	weak var delegate: BADefaultHeaderCellNodeDelegate?
	
	required init(title: String) {
		super.init()
		
		backButtonNode.setImage(UIImage(named:"chat-back"), for: [])
		backButtonNode.addTarget(self, action: #selector(editPressed(_:)), forControlEvents: .touchUpInside)
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.init(name: "Nunito-Bold", size: 18),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		titleNode.attributedText = NSAttributedString(string: title, attributes: nameAttributes)
		
		addSubnode(backButtonNode)
		addSubnode(titleNode)
	}
	
	func editPressed(_ sender: UIButton){
		delegate?.defaultHeaderNodeDidClickBackButton()
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		backButtonNode.style.preferredSize = CGSize(width: 50, height: 50)
		backButtonNode.style.layoutPosition = CGPoint(x: 0, y: 10)
		
		let absoluteSpec = ASAbsoluteLayoutSpec(children: [backButtonNode])
		
		let buttonInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		let buttonSpec = ASInsetLayoutSpec(insets: buttonInsets, child: absoluteSpec)
		
		let titleInsets = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
		let insetSpec = ASInsetLayoutSpec(insets: titleInsets, child: titleNode)
		
		let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: insetSpec)
		
		return ASOverlayLayoutSpec(child: centerSpec, overlay: buttonSpec)
	}
	
}
