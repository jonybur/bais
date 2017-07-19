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
	var age: Int {
		get{
			return Date().years(from: birthday)
		}
	}
	var facebookId = ""
	var firstName = ""
	var lastName = ""
	var countryCode = ""
	var about = ""
	var birthday = Date()
	var notificationToken = ""
	var profilePicture = ""
	var location = CLLocation()
	let imageRatio: CGFloat = (1.3...1.5).random()
	var friendshipStatus: FriendshipStatus = .noRelationship
	
	var country: String{
		get{
			if let countryName = Locale.init(identifier: "en_US").localizedString(forRegionCode: countryCode) {
				return countryName
			}
			return ""
		}
	}
	var fullName: String{
		get{
			return firstName + " " + lastName;
		}
	}
	var fullNameConfidential: String{
		get{
			return firstName + " " + String(lastName.characters.first!) + ".";
		}
	}
	
	var distanceFromUser: Double{
		get {
			return location.distance(from: (CurrentUser.location!))
		}
	}
	
	convenience init (from snapshot: FIRDataSnapshot){
		self.init()
		if let dictionary = snapshot.value as? NSDictionary{
			self.setValuesFromDictionary(dictionary, key: snapshot.key)
		}
	}
    
    convenience init (from dictionary: NSDictionary, and key: String){
        self.init()
        self.setValuesFromDictionary(dictionary, key: key)
    }
	
	private func setValuesFromDictionary(_ dictionary: NSDictionary, key id: String){
		self.id = id
		self.facebookId = dictionary["facebook_id"] as! String
		self.firstName = dictionary["first_name"] as! String
		self.lastName = dictionary["last_name"] as! String
		self.countryCode = dictionary["country_code"] as! String
		self.profilePicture = dictionary["profile_picture"] as! String
		
		if let birthdayValue = dictionary["birthday"] as? String{
			if (birthdayValue == ""){
				self.birthday = Date()
			} else {
				let formatter = DateFormatter()
				formatter.dateFormat = "MM/dd/yyyy"
				
				if (formatter.date(from: birthdayValue) != nil){
					self.birthday = formatter.date(from: birthdayValue)!
				}else{
					self.birthday = Date()
				}
			}
		}
		
		if let notificationTokenFromDictionary = dictionary["notification_token"] as? String {
			self.notificationToken = notificationTokenFromDictionary
		}
		
		if let about = dictionary["about"] as? String{
			self.about = about
		}
		
		if let locationArray = dictionary["location"] as? NSArray{
			let latitude = locationArray[0] as! Double
			let longitude = locationArray[1] as! Double
			self.location = CLLocation(latitude: latitude, longitude: longitude)
		}
	}
	
}
