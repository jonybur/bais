//
//  CGRect+Claxon.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 6/8/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGRect{
    mutating func setNewFrameHeight(_ height: CGFloat) {
        self = CGRect(x: self.origin.x, y: self.origin.y, width: self.width, height: height);
    }
	
	init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
		self.init(x:x, y:y, width:w, height:h)
	}
}

extension CGPoint{
	init(_ x:CGFloat, _ y:CGFloat) {
		self.init(x:x, y:y)
	}
}

// conversions for type operations
extension Int {
	var cgf: CGFloat { return CGFloat(self) }
	var f: Float { return Float(self) }
}

extension Float {
	var cgf: CGFloat { return CGFloat(self) }
}

extension Double {
	var cgf: CGFloat { return CGFloat(self) }
}

extension CGFloat {
	var f: Float { return Float(self) }
}
