//
//  Session.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 19/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class Session{
	var id = ""
	var participants = [String]()
	var messages = [Message]()
	
	convenience init (from snapshot: FIRDataSnapshot){
		self.init()
		self.id = snapshot.key
		if let dictionary = snapshot.value as? NSDictionary{
			self.setValuesFromDictionary(dictionary)
		}
	}
	
	private func setValuesFromDictionary(_ dictionary : NSDictionary){

		guard let participants = dictionary["participants"] as? [String:Bool] else { return }
		
		for (id, status) in participants{
			if (status){
				self.participants.append(id)
			}
		}
		
		print("stop")
		
	}
	
}
