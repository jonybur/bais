//
//  BAChatNavigationBar.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 21/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Foundation

protocol BAChatNavigationBarDelegate: class {
	func chatNavigationBarTapBack(_ chatNavigationBar: BAChatNavigationBar)
	func chatNavigationBarTapSettings(_ chatNavigationBar: BAChatNavigationBar)
	func chatNavigationBarTapProfile(_ chatNavigationBar: BAChatNavigationBar)
}

class BAChatNavigationBar: ASCellNode {
	
	let backButtonNode = ASButtonNode()
	let imageNode = ASNetworkImageNode()
	let nameNode = ASTextNode()
	let settingsButtonNode = ASButtonNode()
	let profileButtonNode = ASButtonNode()
	var user: User?
	weak var delegate: BAChatNavigationBarDelegate?
	
	required init(with user: User){
		super.init()
		self.user = user
		imageNode.setURL(URL(string: user.profilePicture), resetToDefault: false)
		imageNode.shouldRenderProgressImages = true
		imageNode.contentMode = .scaleAspectFill
		imageNode.imageModificationBlock = { image in
			var modifiedImage: UIImage!
			let rect = CGRect(origin: CGPoint(0, 0), size: image.size)
			
			UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
			let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 35, height: 35))
			maskPath.addClip()
			image.draw(in: rect)
			modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return modifiedImage
		}
		
		backgroundColor = .white
		
		backButtonNode.setImage(UIImage(named: "chat-back"), for: [])
		backButtonNode.contentMode = .scaleAspectFit
		backButtonNode.addTarget(self, action: #selector(backButtonPressed(_:)), forControlEvents: .touchUpInside)
		
		settingsButtonNode.setImage(UIImage(named: "chat-more"), for: [])
		settingsButtonNode.contentMode = .scaleAspectFit
		settingsButtonNode.addTarget(self, action: #selector(settingsButtonPressed(_:)), forControlEvents: .touchUpInside)
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: ColorPalette.grey]
		nameNode.attributedText = NSAttributedString(string: user.firstName, attributes: nameAttributes)
		
		profileButtonNode.addTarget(self, action: #selector(profileButtonPressed(_:)), forControlEvents: .touchUpInside)
		
		addSubnode(backButtonNode)
		addSubnode(imageNode)
		addSubnode(nameNode)
		addSubnode(settingsButtonNode)
		addSubnode(profileButtonNode)
	}
	
	func backButtonPressed(_ sender: UIButton){
		delegate?.chatNavigationBarTapBack(self)
	}
	
	func settingsButtonPressed(_ sender: UIButton){
		delegate?.chatNavigationBarTapSettings(self)
	}
	
	func profileButtonPressed(_ sender: UIButton){
		delegate?.chatNavigationBarTapProfile(self)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
				
		// imagen
		let imageLayout = ASRatioLayoutSpec(ratio: 1, child: imageNode)
		imageLayout.style.height = ASDimension(unit: .points, value: 35)
		
		backButtonNode.style.preferredSize = CGSize(width: 40, height: 40)
		settingsButtonNode.style.preferredSize = CGSize(width: 40, height: 40)
		
		let profileSpec = ASStackLayoutSpec()
		profileSpec.direction = .horizontal
		profileSpec.spacing = 10
		profileSpec.alignItems = .center
		profileSpec.children = [imageLayout, nameNode]
		
		let profileOverlayButtonSpec = ASOverlayLayoutSpec(child: profileSpec, overlay: profileButtonNode)
		
		let horizontalSpec = ASStackLayoutSpec()
		horizontalSpec.direction = .horizontal
		horizontalSpec.justifyContent = .spaceBetween
		horizontalSpec.alignItems = .center
		horizontalSpec.children = [backButtonNode, profileOverlayButtonSpec, settingsButtonNode]
		
		let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 25, left: 5, bottom: 10, right: 10), child: horizontalSpec)
		
		return insetSpec
	}
}
