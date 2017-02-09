//
//  BASettingsHeaderCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 8/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class BASettingsHeaderCellNode: ASCellNode{

	let photoNode = ASNetworkImageNode()
	let iconNode = ASImageNode()
	let nameNode = ASTextNode()
	let nationalityNode = ASTextNode()
	
	required init(with user: User) {
		super.init()
		
		iconNode.image = UIImage(named: "edit-button")
		
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
			NSFontAttributeName: UIFont.systemFont(ofSize: 24, weight: UIFontWeightBold),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		nameNode.attributedText = NSAttributedString(string: user.firstName, attributes: nameAndAgeAttributes)
		
		let distanceAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: ColorPalette.grey]
		
		nationalityNode.attributedText = NSAttributedString(string: user.nationality, attributes: distanceAttributes)
		nationalityNode.maximumNumberOfLines = 1
		
		addSubnode(photoNode)
		addSubnode(iconNode)
		addSubnode(nameNode)
		addSubnode(nationalityNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		// imagen
		let imagePlace = ASRatioLayoutSpec(ratio: 1, child: photoNode)
		imagePlace.style.maxWidth = ASDimension(unit: .points, value: 160)
		
		// icono
		iconNode.style.preferredSize = CGSize(width: 45, height: 45)
		iconNode.style.layoutPosition = CGPoint(x: 112.5, y: 112.5)
		
		let absoluteLayout = ASAbsoluteLayoutSpec(sizing: .sizeToFit, children: [imagePlace, iconNode])
		
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
