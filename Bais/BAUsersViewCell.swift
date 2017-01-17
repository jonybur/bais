//
//  ImageCellNode.swift
//  Sample
//
//  Created by Rajeev Gupta on 11/9/16.
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree. An additional grant
//  of patent rights can be found in the PATENTS file in the same directory.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
//  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import AsyncDisplayKit
import Foundation
import FirebaseDatabase
import Firebase

protocol BAUsersViewCellDelegate: class {
	func usersViewCellDidClickView(_ usersViewCell: BAUsersViewCell);
	func usersViewCellDidClickButton(_ usersViewCell: BAUsersViewCell);
}

class BAUsersViewCell: ASCellNode {
	
	let imageNode = ASNetworkImageNode()
	let nameNode = ASTextNode()
	let distanceNode = ASTextNode()
	let buttonNode = ASButtonNode()
	var cardUser: User!
	var ratio: CGSize!
	
	weak var delegate : BAUsersViewCellDelegate?
	
	required init(with user : User) {
		super.init()
		
		cardUser = user
		
		imageNode.setURL(URL(string: user.profilePicture), resetToDefault: false)
		imageNode.shouldRenderProgressImages = true
		imageNode.contentMode = .scaleAspectFill
		
		let shadow : NSShadow = NSShadow()
		shadow.shadowColor = UIColor.black
		shadow.shadowBlurRadius = 2
		shadow.shadowOffset = CGSize(width: 0, height: 0)
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: UIColor.white,
			NSShadowAttributeName: shadow]
		
		let distanceAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight),
			NSForegroundColorAttributeName: UIColor.white,
			NSShadowAttributeName: shadow]
		
		nameNode.attributedText = NSAttributedString(string: cardUser.firstName, attributes: nameAttributes)
		
		let distanceString = self.cardUser.location.distance(from: CurrentUser.location!).redacted()
		distanceNode.attributedText = NSAttributedString(string: distanceString, attributes: distanceAttributes)
		distanceNode.maximumNumberOfLines = 1
		
		ratio = CGSize(width:1,height:user.imageRatio)
		
		buttonNode.backgroundColor = ColorPalette.baisWhite
		//self.setButtonTitle("Invite")
		//buttonNode.addTarget(self, action: #selector(buttonPressed(sender:)), forControlEvents: .touchUpInside)
		buttonNode.addTarget(self, action: #selector(self.buttonPressed(_:)), forControlEvents: .touchUpInside)

		self.setFriendshipAction()
		
		//self.addTarget(self, action: #selector(cardPressed(sender:)), forControlEvents: .touchUpInside)
		
		self.addSubnode(self.imageNode)
		self.addSubnode(self.nameNode)
		self.addSubnode(self.distanceNode)
		self.addSubnode(self.buttonNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		// imagen
		let imagePlace = ASRatioLayoutSpec(ratio: self.ratio.height, child: imageNode)
		imagePlace.style.minWidth = ASDimension(unit: .points, value: constrainedSize.max.width)
		
		// stack
		let textStack = ASStackLayoutSpec()
		textStack.direction = .vertical
		textStack.alignItems = .start
		textStack.children = [nameNode, distanceNode]
		
		// text inset
		let textInsets = UIEdgeInsets(top: CGFloat.infinity, left: 10, bottom: 10, right: 10)
		let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: textStack)
		
		// overlay imagen + texto
		let overlayLayout = ASOverlayLayoutSpec(child: imagePlace, overlay: textInsetSpec)
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
	
	func cardPressed(_ sender: UIButton){
		delegate?.usersViewCellDidClickView(self);
	}
	
	func buttonPressed(_ sender: UIButton){
		delegate?.usersViewCellDidClickButton(self)
	}
	
	func setButtonTitle(_ title: String){
		self.buttonNode.setTitle(title, with: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium), with: ColorPalette.baisOrange, for: [])
	}
	
	func setFriendshipAction(){
		switch (cardUser.friendshipStatus){
			case .accepted:
				self.setButtonTitle("Chat")
				break;
			case .invited:
				self.setButtonTitle("Request Sent")
				break;
			default:
				self.setButtonTitle("Invite")
				break;
		}
	}
}
