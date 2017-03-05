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
		frame = CGRect(x: ez.screenWidth / 2 - ez.screenWidth / 4, y: ez.screenHeight - 60, width: ez.screenWidth / 2, height: 50)
		alpha = 0.5
		isEnabled = false
		let yourCarefullyDrawnPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), cornerRadius: 20)
		let maskForYourPath = CAShapeLayer()
		maskForYourPath.path = yourCarefullyDrawnPath.cgPath
		layer.mask = maskForYourPath
	}
	
	func enable(){
		alpha = 1
		isEnabled = true
	}
	
}
