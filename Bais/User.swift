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

class CurrentUser{
	//open static var instance : User?;
	open static var location : CLLocation?;
	
	/*
	thisUserRef.observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot!) in
		CurrentUser.instance = User(fromSnapshot: snapshot);
	}
	*/
}

class User{
	var id : String = "";
	var facebookId : String = "";
	var firstName : String = "";
	var lastName : String = "";
	var nationality : String = "";
	var location : CLLocation = CLLocation();
	var profilePicture : String = "";
	
	func fullName()->String{
		return firstName + " " + lastName;
	}
	
	func fullNameConfidential()->String{
		return firstName + " " + String(lastName.characters.first!) + ".";
	}
	
	convenience init (fromSnapshot : FIRDataSnapshot){
		
		self.init();
		setValuesFromSnapshot(fromSnapshot);
		
	}
	
	private func setValuesFromSnapshot(_ fromSnapshot : FIRDataSnapshot){
		
		if let dictionary = fromSnapshot.value as? NSDictionary{
			
			self.id = fromSnapshot.key;
			self.facebookId = dictionary["facebook_id"] as! String;
			self.firstName = dictionary["first_name"] as! String;
			self.lastName = dictionary["last_name"] as! String;
			self.nationality = dictionary["nationality"] as! String;
			self.profilePicture = dictionary["profile_picture"] as! String;
			
			if let locationDictionary = dictionary["location"] as? NSDictionary{
				let latitude = locationDictionary["lat"] as! Double;
				let longitude = locationDictionary["lon"] as! Double;
				
				self.location = CLLocation(latitude: latitude, longitude: longitude);
			}
			
		}

	}

}
