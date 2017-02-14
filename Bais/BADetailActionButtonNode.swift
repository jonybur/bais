//
//  BADetailActionButtonNode.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 14/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class BADetailActionButtonNode: ASButtonNode {
	
	override init() {
		super.init()
		
		backgroundColor = ColorPalette.orange
		setTitle("Done", with: UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular), with: .white, for: [])
		style.preferredSize = CGSize(width: 300, height: 50)
		alpha = 0.5
		isEnabled = false
	}
	
	func enable(){
		alpha = 1
		isEnabled = true
	}
	
}
