//
//  BAUsersCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 19/1/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Foundation
import FirebaseDatabase
import Firebase

protocol BAUsersCellNodeDelegate: class {
	func usersCellNodeDidClickView(_ usersViewCell: BAUsersCellNode);
	func usersCellNodeDidClickButton(_ usersViewCell: BAUsersCellNode);
}

class BAUsersCellNode: ASCellNode {
	
	let imageNode = ASNetworkImageNode()
	let nameNode = ASTextNode()
	let distanceNode = ASTextNode()
	let flagNode = ASImageNode()
	let buttonNode = ASButtonNode()
	
	var gradientNode = ASDisplayNode()
	var user: User!
	var ratio: CGSize!
	
	weak var delegate: BAUsersCellNodeDelegate?
	
	required init(with user: User) {
		super.init()
		
		self.user = user
		
		imageNode.setURL(URL(string: user.profilePicture), resetToDefault: false)
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
			NSFontAttributeName: UIFont.init(name: "Nunito-SemiBold", size: 15),
			NSForegroundColorAttributeName: UIColor.white]
		
		let distanceAttributes = [
			NSFontAttributeName: UIFont.init(name: "Nunito-Regular", size: 13),
			NSForegroundColorAttributeName: UIColor.white]
		
		var nameAndAgeString = user.firstName
		if (user.age > 0){
			nameAndAgeString += ", " + String(user.age)
		}
		nameNode.attributedText = NSAttributedString(string: nameAndAgeString, attributes: nameAttributes)
		
		let distanceString = self.user.location.distance(from: CurrentUser.location!).redacted()
		distanceNode.attributedText = NSAttributedString(string: distanceString, attributes: distanceAttributes)
		distanceNode.maximumNumberOfLines = 1
		
		ratio = CGSize(width:1,height:user.imageRatio)
		
		imageNode.addTarget(self, action: #selector(cardPressed(_:)), forControlEvents: .touchUpInside)
		buttonNode.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .touchUpInside)

		setFriendshipAction()

		gradientNode = ASDisplayNode(layerBlock: { () -> CALayer in
			let gradient = CAGradientLayer()
			gradient.colors = [UIColor.clear.cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor]
			return gradient
		})
		
		flagNode.image = UIImage(named: user.countryCode)
		
		imageNode.clipsToBounds = true;
		
		addSubnode(imageNode)
		addSubnode(nameNode)
		addSubnode(flagNode)
		addSubnode(distanceNode)
		addSubnode(buttonNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		// imagen
		let imageLayout = ASRatioLayoutSpec(ratio: self.ratio.height, child: imageNode)
		imageLayout.style.minWidth = ASDimension(unit: .points, value: constrainedSize.max.width)
		
		flagNode.style.preferredSize = CGSize(width: 20, height: 20)
		
		let spacerSpec = ASLayoutSpec()
		spacerSpec.style.flexGrow = 1.0
		spacerSpec.style.flexShrink = 1.0
		
		// text stack
		let textStack = ASStackLayoutSpec()
		textStack.direction = .vertical
		textStack.alignItems = .start
		textStack.children = [flagNode, spacerSpec, nameNode, distanceNode]
		
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
		buttonNode.contentVerticalAlignment = .center
		buttonNode.contentHorizontalAlignment = .middle

		// stack
		let verticalStack = ASStackLayoutSpec()
		verticalStack.direction = .vertical
		verticalStack.alignItems = .center
		verticalStack.children = [overlayLayout, buttonNode]
		
		return verticalStack
	}
	
	//MARK: - BAUsersCellNodeDelegate methods
	
	func cardPressed(_ sender: UIButton){
		delegate?.usersCellNodeDidClickView(self);
	}
	
	func buttonPressed(_ sender: UIButton){
		delegate?.usersCellNodeDidClickButton(self)
	}
	
	func setFriendshipAction(){
		switch (user.friendshipStatus){
			case .accepted:
				setButtonTitle("Chat", ColorPalette.orange)
				break;
			case .invitationSent:
				setButtonTitle("Invite sent")
				break;
			case .invitationReceived:
				setButtonTitle("Invited you")
				break;
			default:
				setButtonTitle("Invite")
				break;
		}
	}
    
    func setButtonTitle(_ title: String, _ color: UIColor){
        self.buttonNode.setTitle(title, with: UIFont.init(name: "Nunito-SemiBold", size: 14), with: color, for: [])
    }
	
	func setButtonTitle(_ title: String){
		self.setButtonTitle(title, ColorPalette.grey)
	}
}
