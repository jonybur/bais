//
//  User.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 26/9/16.
//  Copyright © 2016 Board Social, Inc. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class CurrentUser {
	open static var location: CLLocation?
	open static var user: User!
}

class User{
	
	var id = ""
	var age: Int = 23
	var facebookId = ""
	var firstName = ""
	var lastName = ""
	var countryCode = ""
	var lastMessage = ""
	var about = ""
	var profilePicture = ""
	var location = CLLocation()
	var country: String{
		get{
			if let countryName = Locale.init(identifier: "en_US").localizedString(forRegionCode: countryCode) {
				return countryName
			}
			return ""
		}
	}
	let imageRatio: CGFloat = (1.3...1.5).random()
	var friendshipStatus: FriendshipStatus = .undefined
	
	func fullName()->String{
		return firstName + " " + lastName;
	}
	
	func fullNameConfidential()->String{
		return firstName + " " + String(lastName.characters.first!) + ".";
	}
	
	convenience init (fromNSDictionary : NSDictionary){
		self.init()
		self.setValuesFromDictionary(fromNSDictionary)
	}
	
	convenience init (fromSnapshot : FIRDataSnapshot){
		self.init()
		if let dictionary = fromSnapshot.value as? NSDictionary{
			self.setValuesFromDictionary(dictionary)
		}
	}
	
	var distanceFromUser: Double{
		get {
			return location.distance(from: (CurrentUser.location!))
		}
	}
	
	private func setValuesFromDictionary(_ dictionary : NSDictionary){
		self.id = dictionary["id"] as! String
		self.facebookId = dictionary["facebook_id"] as! String
		self.firstName = dictionary["first_name"] as! String
		self.lastName = dictionary["last_name"] as! String
		self.countryCode = dictionary["country_code"] as! String
		self.profilePicture = dictionary["profile_picture"] as! String
		
		if let about = dictionary["about"] as? String{
			self.about = about
		}
		
		if let locationDictionary = dictionary["location"] as? NSDictionary{
			let latitude = locationDictionary["lat"] as! Double
			let longitude = locationDictionary["lon"] as! Double
			self.location = CLLocation(latitude: latitude, longitude: longitude)
		}
	}
	
}
