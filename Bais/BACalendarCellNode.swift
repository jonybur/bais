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
	
	// sets the proper status for event
	func calendarCellNodeDidClickInterestedButton(_ calendarViewCell: BACalendarCellNode);
	func calendarCellNodeDidClickGoingButton(_ calendarViewCell: BACalendarCellNode);

	// user is already interested or going
	func calendarCellNodeDidClickIsInterestedButton(_ calendarViewCell: BACalendarCellNode);
	func calendarCellNodeDidClickIsGoingButton(_ calendarViewCell: BACalendarCellNode);
}

class BACalendarCellNode: ASCellNode {
	
	let imageNode = ASNetworkImageNode()
	let nameNode = ASTextNode()
	let distanceNode = ASTextNode()
	let singleButtonNode = ASButtonNode()

	let leftButtonNode = ASButtonNode()
	let rightButtonNode = ASButtonNode()

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
			
			let gradientImage = image.tintedWithLinearGradientColors(colorsArr: [UIColor.init(white: 0, alpha: 0.75).cgColor, UIColor.clear.cgColor])
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
			NSFontAttributeName: UIFont.init(name: "SourceSansPro-SemiBold", size: 15),
			NSForegroundColorAttributeName: UIColor.white]
		
		let distanceAttributes = [
			NSFontAttributeName: UIFont.init(name: "SourceSansPro-Regular", size: 13),
			NSForegroundColorAttributeName: UIColor.white]
		
		nameNode.attributedText = NSAttributedString(string: self.event.name, attributes: nameAttributes)
		
		let distanceString = event.redactedDate()
		distanceNode.attributedText = NSAttributedString(string: distanceString, attributes: distanceAttributes)
		distanceNode.maximumNumberOfLines = 1
		
		imageNode.addTarget(self, action: #selector(self.bannerPressed(_:)), forControlEvents: .touchUpInside)
		singleButtonNode.addTarget(self, action: #selector(self.singleButtonPressed(_:)), forControlEvents: .touchUpInside)
		leftButtonNode.addTarget(self, action: #selector(self.leftButtonPressed(_:)), forControlEvents: .touchUpInside)
		rightButtonNode.addTarget(self, action: #selector(self.rightButtonPressed(_:)), forControlEvents: .touchUpInside)
		
		gradientNode = ASDisplayNode(layerBlock: { () -> CALayer in
			let gradient = CAGradientLayer()
			gradient.colors = [UIColor.clear.cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor]
			return gradient
		})
		
		setButtonsFor(rsvpStatus: event.status)
		
		imageNode.clipsToBounds = true;
		
		addSubnode(imageNode)
		addSubnode(nameNode)
		addSubnode(distanceNode)
		addSubnode(singleButtonNode)
		addSubnode(leftButtonNode)
		addSubnode(rightButtonNode)
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
		overlayLayout.style.minHeight = ASDimension (unit: .fraction, value: 1)
		overlayLayout.style.flexShrink = 1
		
		// bottom button
		singleButtonNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 50)
		singleButtonNode.contentVerticalAlignment = .center
		singleButtonNode.contentHorizontalAlignment = .middle
		
		// left button
		leftButtonNode.style.preferredSize = CGSize(width: constrainedSize.max.width / 2, height: 50)
		leftButtonNode.contentVerticalAlignment = .center
		leftButtonNode.contentHorizontalAlignment = .middle
		
		// right button
		rightButtonNode.style.preferredSize = CGSize(width: constrainedSize.max.width / 2, height: 50)
		rightButtonNode.contentVerticalAlignment = .center
		rightButtonNode.contentHorizontalAlignment = .middle
		
		// horizontal stack
		let horizontalButtonStack = ASStackLayoutSpec()
		horizontalButtonStack.direction = .horizontal
		horizontalButtonStack.alignItems = .start
		horizontalButtonStack.children = [leftButtonNode, rightButtonNode]
		
		// stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .center
		
		if (event.status == .declined){
			verticalStack.children = [overlayLayout, horizontalButtonStack]
		} else {
			verticalStack.children = [overlayLayout, singleButtonNode]
		}
		
		return verticalStack
	}
	
	//MARK: - BAUsersCellNodeDelegate methods
	
	func bannerPressed(_ sender: UIButton){
		delegate?.calendarCellNodeDidClickView(self)
	}
	
	func singleButtonPressed(_ sender: UIButton){
		if (event.status == .undefined){
			return
		} else if (event.status == .maybe){
			delegate?.calendarCellNodeDidClickIsInterestedButton(self)
		} else if (event.status == .attending){
			delegate?.calendarCellNodeDidClickIsGoingButton(self)
		}
	}
	
	func leftButtonPressed(_ sender: UIButton){
		delegate?.calendarCellNodeDidClickInterestedButton(self)
	}
	
	func rightButtonPressed(_ sender: UIButton){
		delegate?.calendarCellNodeDidClickGoingButton(self)
	}

	func setButtonsFor(rsvpStatus: RSVPStatus){
		switch(rsvpStatus){
		case .declined:
			// 2 buttons, "interested" and "going"
			leftButtonNode.setTitle("Interested", with: UIFont.init(name: "SourceSansPro-SemiBold", size: 14), with: ColorPalette.grey, for: [])
			rightButtonNode.setTitle("Going", with: UIFont.init(name: "SourceSansPro-SemiBold", size: 14), with: ColorPalette.grey, for: [])
			break
		case .maybe:
			// 1 button, "interested"
			singleButtonNode.setTitle("Interested", with: UIFont.init(name: "SourceSansPro-SemiBold", size: 14), with: ColorPalette.grey, for: [])
			break
		case .attending:
			// 1 button, "going"
			singleButtonNode.setTitle("Going", with: UIFont.init(name: "SourceSansPro-SemiBold", size: 14), with: ColorPalette.grey, for: [])
			break
		case .undefined:
			singleButtonNode.setTitle("", with: UIFont.init(name: "SourceSansPro-SemiBold", size: 14), with: ColorPalette.grey, for: [])
			break
		}
	}
	
}
