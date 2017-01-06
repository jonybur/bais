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

class BSWaterfallViewCell: ASCellNode, ASNetworkImageNodeDelegate {
	
	let imageNode = ASNetworkImageNode();
	var cardUser : User!;
	var friendshipStatus : FriendshipStatus = .undefined;
	var ratio : CGSize!;
	weak var delegate : UserCardDelegate?;
	
	required init(with user : User) {
		super.init()
		
		cardUser = user
		
		imageNode.setURL(URL(string: user.profilePicture), resetToDefault: false);
		imageNode.shouldRenderProgressImages = true;
		imageNode.delegate = self;
		ratio = CGSize(width:0,height:0);
		
		self.addSubnode(self.imageNode)
	}
	
	func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
		
		if imageNode.image != nil {
			ratio = CGSize(width: (imageNode.image?.size.height)!, height: (imageNode.image?.size.width)!)
		}
		
	}
		
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let imageRatio: CGFloat = 1
		
		ratio = CGSize(width: imageRatio, height: imageRatio)
		
		let imagePlace = ASRatioLayoutSpec(ratio: imageRatio, child: imageNode)
		let stackLayout = ASStackLayoutSpec.horizontal()
		
		stackLayout.justifyContent = .start
		stackLayout.alignItems = .start
		stackLayout.style.flexShrink = 1.0
		stackLayout.children = [imagePlace]
		
		return  ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: stackLayout)
	}
	
}
