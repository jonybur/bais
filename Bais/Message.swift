//
//  File.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 19/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import CoreGraphics

class Message{
	var text = ""
	var senderId = ""
	var timestamp: CGFloat = 0
	
	init(){
	}
	
	init(text: String, senderId: String){
		self.text = text
		self.senderId = senderId
	}
}
