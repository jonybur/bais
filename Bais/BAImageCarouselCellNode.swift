//
//  BAImageCarouselCellNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 4/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Foundation

protocol BAImageCarouselCellNodeDelegate: class {
	func imageCarouselCellNodeDidClickBackButton(_ usersViewCell: BAImageCarouselCellNode);
}

class BAImageCarouselCellNode: ASCellNode {
	
	let backButtonNode = ASButtonNode()
	let imageNode = ASNetworkImageNode()
	
	weak var delegate: BAImageCarouselCellNodeDelegate?
	
	required init(with user: User) {
		super.init()
		
		imageNode.setURL(URL(string: user.profilePicture), resetToDefault: false)
		imageNode.shouldRenderProgressImages = true
		imageNode.contentMode = .scaleAspectFill
		
		backButtonNode.addTarget(self, action: #selector(self.backButtonPressed(_:)), forControlEvents: .touchUpInside)
		
		self.addSubnode(self.imageNode)
	}
	
	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		// imagen
		let imageLayout = ASRatioLayoutSpec(ratio: 1, child: imageNode)
		imageLayout.style.minWidth = ASDimension(unit: .points, value: constrainedSize.max.width)
		
		return imageLayout
	}
	
	//MARK: - BAUsersCellNodeDelegate methods
	
	func backButtonPressed(_ sender: UIButton){
		delegate?.imageCarouselCellNodeDidClickBackButton(self)
	}
	
}
