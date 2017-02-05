//
//  BACalendarCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 4/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Foundation
import FirebaseDatabase
import Firebase

protocol BACalendarCellNodeDelegate: class {
	func calendarCellNodeDidClickView(_ calendarViewCell: BACalendarCellNode);
	func calendarCellNodeDidClickButton(_ calendarViewCell: BACalendarCellNode);
}

class BACalendarCellNode: ASCellNode {
	
	let imageNode = ASNetworkImageNode()
	let nameNode = ASTextNode()
	let distanceNode = ASTextNode()
	let buttonNode = ASButtonNode()
	
	var gradientNode = ASDisplayNode()
	var event: Event!
	
	weak var delegate: BACalendarCellNodeDelegate?
	
	required init(with event: Event) {
		super.init()
		
		self.event = event
		
		imageNode.setURL(URL(string: event.imageUrl), resetToDefault: false)
		imageNode.shouldRenderProgressImages = true
		imageNode.contentMode = .scaleAspectFill
		imageNode.imageModificationBlock = { image in
			var modifiedImage: UIImage!
			let rect = CGRect(origin: CGPoint(0, 0), size: image.size)
			UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
			
			let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10))
			maskPath.addClip()
			image.draw(in: rect)
			
			let gradientImage = image.tintedWithLinearGradientColors(colorsArr: [UIColor.init(white: 0, alpha: 0.6).cgColor, UIColor.clear.cgColor])
			gradientImage.draw(in: CGRect(origin: CGPoint(0, gradientImage.size.height / 2), size: gradientImage.size))
			modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			
			return modifiedImage
		}
		
		let shadow = NSShadow()
		shadow.shadowColor = UIColor.black
		shadow.shadowBlurRadius = 2
		shadow.shadowOffset = CGSize(width: 0, height: 0)
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: UIColor.white]
		
		let distanceAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight),
			NSForegroundColorAttributeName: UIColor.white]
		
		nameNode.attributedText = NSAttributedString(string: self.event.name, attributes: nameAttributes)
		
		let distanceString = event.redactedDate()
		distanceNode.attributedText = NSAttributedString(string: distanceString, attributes: distanceAttributes)
		distanceNode.maximumNumberOfLines = 1
		
		imageNode.addTarget(self, action: #selector(self.cardPressed(_:)), forControlEvents: .touchUpInside)
		buttonNode.addTarget(self, action: #selector(self.buttonPressed(_:)), forControlEvents: .touchUpInside)
				
		gradientNode = ASDisplayNode(layerBlock: { () -> CALayer in
			let gradient = CAGradientLayer()
			gradient.colors = [UIColor.clear.cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor]
			return gradient
		})
		
		
		self.imageNode.clipsToBounds = true;
		
		self.addSubnode(self.imageNode)
		self.addSubnode(self.nameNode)
		self.addSubnode(self.distanceNode)
		self.addSubnode(self.buttonNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// imagen
		let imageLayout = ASRatioLayoutSpec(ratio: 1, child: imageNode)
		imageLayout.style.minWidth = ASDimension(unit: .points, value: constrainedSize.max.width)
		
		let spacerSpec = ASLayoutSpec()
		spacerSpec.style.flexGrow = 1.0
		spacerSpec.style.flexShrink = 1.0
		
		// text stack
		let textStack = ASStackLayoutSpec()
		textStack.direction = .vertical
		textStack.alignItems = .start
		textStack.children = [spacerSpec, nameNode, distanceNode]
		
		// text stack inset
		let textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 10, right: 10)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: textStack)
		
		// overlay imagen + texto
		let overlayLayout = ASOverlayLayoutSpec(child: imageLayout, overlay: textInsetSpec)
		overlayLayout.style.flexBasis = ASDimension (unit: .fraction, value: 0.8)
		overlayLayout.style.flexShrink = 1
		
		// bottom button
		buttonNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 50)
		buttonNode.style.flexBasis = ASDimension (unit: .fraction, value: 0.2)
		buttonNode.style.flexShrink = 1
		buttonNode.contentVerticalAlignment = .alignmentCenter
		buttonNode.contentHorizontalAlignment = .horizontalAlignmentMiddle
		
		// stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .center
		verticalStack.children = [overlayLayout, buttonNode]
		
		return verticalStack
	}
	
	//MARK: - BAUsersCellNodeDelegate methods
	
	func cardPressed(_ sender: UIButton){
		delegate?.calendarCellNodeDidClickView(self);
	}
	
	func buttonPressed(_ sender: UIButton){
		delegate?.calendarCellNodeDidClickButton(self)
	}
	
	func setButtonTitle(_ title: String){
		self.buttonNode.setTitle(title, with: UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium), with: ColorPalette.grey, for: [])
	}

}
