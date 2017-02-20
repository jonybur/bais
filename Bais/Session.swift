//
//  Session.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 19/2/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import PromiseKit
import Firebase
import CoreLocation

class Session{
	var id = ""
	var lastMessage = ""
	var participants = [User]()
	var messages = [Message]()
	
	convenience init (from snapshot: FIRDataSnapshot){
		self.init()
		self.id = snapshot.key
		
		//guard let dictionary = snapshot.value as? NSDictionary else { return }
		//self.setValuesFromDictionary(dictionary)
	}
	
	/*
	private func setValuesFromDictionary(_ dictionary: NSDictionary){
		
	}
	*/
	
	func loadParticipants(from snapshot: FIRDataSnapshot) -> Promise<Void>{
		return Promise{ fulfill, reject in
			guard let dictionary = snapshot.value as? NSDictionary else { return fulfill() }
			guard let participants = dictionary["participants"] as? [String:Bool] else { return fulfill() }
			
			for (id, status) in participants{
				if (status){
					FirebaseService.getUser(with: id).then(execute: { user -> Void in
						self.participants.append(user)
						if (participants.count == self.participants.count){
							fulfill()
						}
					}).catch(execute: { _ in })
				}
			}
		}
	}
	
}
