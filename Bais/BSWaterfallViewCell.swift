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

class BSWaterfallViewCell: ASCellNode {
	
	let imageNode = ASNetworkImageNode()
	let nameNode = ASTextNode()
	let testNode = ASImageNode()
	let buttonNode = ASButtonNode()
	var cardUser: User!
	var ratio: CGSize!
	
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
		
		nameNode.attributedText = NSAttributedString(string: cardUser.firstName, attributes: nameAttributes)
		
		ratio = CGSize(width:1,height:user.imageRatio)
		
		buttonNode.backgroundColor = ColorPalette.baisWhite
		buttonNode.setTitle("Button", with: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium), with: ColorPalette.baisOrange, for: [])
		
		self.addSubnode(self.imageNode)
		self.addSubnode(self.nameNode)
		self.addSubnode(self.buttonNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		// imagen
		let imagePlace = ASRatioLayoutSpec(ratio: self.ratio.height, child: imageNode)
		imagePlace.style.minWidth = ASDimension(unit: .points, value: constrainedSize.max.width)
		
		// texto
		let insets = UIEdgeInsets(top: CGFloat.infinity, left: 10, bottom: 10, right: 10)
		let textInsetSpec = ASInsetLayoutSpec(insets: insets, child: nameNode)
		
		// overlay imagen + texto
		let overlayLayout = ASOverlayLayoutSpec(child: imagePlace, overlay: textInsetSpec)
		overlayLayout.style.flexBasis = ASDimension (unit: .fraction, value: 0.8)
		overlayLayout.style.flexShrink = 1
		
		// bottom button
		buttonNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 45)
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
}
