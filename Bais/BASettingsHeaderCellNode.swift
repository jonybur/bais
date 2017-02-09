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
	let nameNode = ASTextNode()
	let nationalityNode = ASTextNode()
	
	required init(with user: User) {
		super.init()
		
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
		
		self.addSubnode(photoNode)
		self.addSubnode(nameNode)
		self.addSubnode(nationalityNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		// imagen
		let imagePlace = ASRatioLayoutSpec(ratio: 1, child: photoNode)
		imagePlace.style.maxWidth = ASDimension(unit: .points, value: 160)
		
		// vertical stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .center
		verticalStack.justifyContent = .spaceAround
		verticalStack.spacing = 6
		verticalStack.children = [imagePlace, nameNode, nationalityNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: 60, left: 0, bottom: 50, right: 0)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: verticalStack)
		
		return textInsetSpec
	}
	
}
