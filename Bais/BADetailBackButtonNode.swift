//
//  BADetailBackButtonNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 14/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class BADetailBackButtonNode: ASButtonNode {
	
	override init() {
		super.init()
		
		frame = CGRect(x: 0, y: 10, width: 75, height: 75)
		style.preferredSize = CGSize(width: 75, height: 75)
		setImage(UIImage(named: "back-button"), for: [])
	}
	
}
