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
	var cardUser: User!
	var ratio: CGSize!
	
	required init(with user : User) {
		super.init()
		
		cardUser = user
		
		imageNode.setURL(URL(string: user.profilePicture), resetToDefault: false);
		imageNode.shouldRenderProgressImages = true;
		
		let shadow : NSShadow = NSShadow()
		shadow.shadowColor = UIColor.black
		shadow.shadowBlurRadius = 2
		shadow.shadowOffset = CGSize(width: 0, height: 0);
		
		let nameAttributes = [
			NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium),
			NSForegroundColorAttributeName: UIColor.white,
			NSShadowAttributeName: shadow]
		
		nameNode.attributedText = NSAttributedString(string: cardUser.firstName, attributes: nameAttributes)
		
		ratio = CGSize(width:1,height:user.imageRatio)
		
		self.addSubnode(self.imageNode)
		self.addSubnode(self.nameNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		
		let imagePlace = ASRatioLayoutSpec(ratio: self.ratio.height, child: imageNode)
		
		// INFINITY is used to make the inset unbounded
		let insets = UIEdgeInsets(top: CGFloat.infinity, left: 12, bottom: 12, right: 12)
		let textInsetSpec = ASInsetLayoutSpec(insets: insets, child: nameNode)
		
		return ASOverlayLayoutSpec(child: imagePlace, overlay: textInsetSpec)
	}
}
