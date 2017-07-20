//
//  BASettingsHeaderCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 8/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol BASettingsHeaderNodeDelegate: class {
	func settingsHeaderNodeDidClickEditButton()
}

class BASettingsHeaderCellNode: ASCellNode{

	let photoNode = ASNetworkImageNode()
	let editButtonNode = ASButtonNode()
	let nameNode = ASTextNode()
	let nationalityNode = ASTextNode()
	weak var delegate: BASettingsHeaderNodeDelegate?
	
	required init(with user: User) {
		super.init()
		
		editButtonNode.setImage(UIImage(named: "edit-button"), for: [])
		
		photoNode.setURL(URL(string: user.profilePicture), resetToDefault: false)
		photoNode.shouldRenderProgressImages = true
		photoNode.contentMode = .scaleAspectFill
		photoNode.imageModificationBlock = { image in
			var modifiedImage: UIImage!
			let rect = CGRect(origin: CGPoint(0, 0), size: image.size)
			
			UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
			let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 160, height: 160))
			maskPath.addClip()
			image.draw(in: rect)
			modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return modifiedImage
		}
		
		let nameAndAgeAttributes = [
			NSFontAttributeName: UIFont.init(name: "SourceSansPro-Bold", size: 24),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		nameNode.attributedText = NSAttributedString(string: user.firstName, attributes: nameAndAgeAttributes)
		
		let distanceAttributes = [
			NSFontAttributeName: UIFont.init(name: "SourceSansPro-SemiBold", size: 16),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		nationalityNode.attributedText = NSAttributedString(string: user.country, attributes: distanceAttributes)
		nationalityNode.maximumNumberOfLines = 1
		
		editButtonNode.addTarget(self, action: #selector(editPressed(_:)), forControlEvents: .touchUpInside)
		
		addSubnode(photoNode)
		addSubnode(editButtonNode)
		addSubnode(nameNode)
		addSubnode(nationalityNode)
	}
	
	func editPressed(_ sender: UIButton){
		delegate?.settingsHeaderNodeDidClickEditButton()
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		// imagen
		let imagePlace = ASRatioLayoutSpec(ratio: 1, child: photoNode)
		imagePlace.style.maxWidth = ASDimension(unit: .points, value: 160)
		
		// icono
		editButtonNode.style.layoutPosition = CGPoint(x: 112.5, y: 112.5)
		let absoluteLayout = ASAbsoluteLayoutSpec(sizing: .sizeToFit, children: [imagePlace, editButtonNode])
		
		// vertical stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .center
		verticalStack.justifyContent = .spaceAround
		verticalStack.spacing = 6
		verticalStack.children = [absoluteLayout, nameNode, nationalityNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: 55, left: 0, bottom: 35, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: verticalStack)
		
		return textInsetSpec
	}
	
}
