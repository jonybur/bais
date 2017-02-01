//
//  FirebaseAPI.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 26/9/16.
//  Copyright © 2016 Board Social, Inc. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import CoreLocation
import GeoFire

let registerUserKey = "com.baisapp.registerUser";

class FirebaseAPI{
	
	static let rootReference = FIRDatabase.database().reference()
	
	static func updateUserLocation(_ location: CLLocationCoordinate2D){
		
		let currentUserId = (FIRAuth.auth()?.currentUser?.uid)!
		let geoFire = GeoFire(firebaseRef: rootReference)
		let locationRef = rootReference.child("users").child(currentUserId).child("location")
		
		let value = [
			"lon": location.longitude,
			"lat": location.latitude
		];
		
		locationRef.updateChildValues(value)
		geoFire?.setLocation(CLLocation(latitude: location.latitude, longitude: location.longitude), forKey: currentUserId)
		CurrentUser.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
	}
	
	static func endFriendRelationshipWith(friendId : String){
		let currentUserId = (FIRAuth.auth()?.currentUser?.uid)!;
		
		let selfRef = rootReference.child("users").child(currentUserId).child("friends").child(friendId);
		let friendRef = rootReference.child("users").child(friendId).child("friends").child(currentUserId);
	
		selfRef.removeValue();
		friendRef.removeValue();
	}
	
	static func denyFriendRequestFrom(friendId : String){
		let currentUserId = (FIRAuth.auth()?.currentUser?.uid)!
		
		let selfRef = rootReference.child("users").child(currentUserId).child("friends").child(friendId);
		selfRef.removeValue();
	}
	
	static func acceptFriendRequestFrom(friendId : String){
		setFriendStatusWith(friendId, to : .accepted);
	}
	
	static func sendFriendRequestTo(friendId : String){
		setFriendStatusWith(friendId, to : .invited);
	}
	
	private static func setFriendStatusWith(_ friendId : String, to status : FriendshipStatus){
		let currentUserId = (FIRAuth.auth()?.currentUser?.uid)!;
		
		var value = [String:String]();
		
		switch (status){
		
		case .accepted:
			value = [
				"status": status.rawValue
			];
			break;
			
		case .invited:
			value = [
				"status": status.rawValue,
				"postedBy": currentUserId
			];
			break;
			
		default: break;
		
		}
		
		let selfRef = rootReference.child("users").child(currentUserId).child("friends").child(friendId)
		selfRef.updateChildValues(value);
		
		let friendRef = rootReference.child("users").child(friendId).child("friends").child(currentUserId)
		friendRef.updateChildValues(value);
	}
	
	// takes Firebase user, adds Facebook information, posts to database
	static func registerUser(_ user : FIRUser){
		
		if FBSDKAccessToken.current() == nil {
			return;
		}
		
		let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me",
		                                                        parameters: ["fields": "picture.width(400),first_name,last_name"],
		                                                        httpMethod: "GET");
		
		graphRequest.start { connection, result, error in
			if error != nil {
				print("ERROR: " + error.debugDescription)
				return;
			}
			
			if let nsArray = result as? NSDictionary {
				
				if let events = nsArray.object(forKey: "picture") as? NSDictionary{
					
					if let datum = events["data"] as? NSDictionary{
					
						let messageRef = rootReference.child("users");
						let itemRef = messageRef.child(user.uid);
						let userItem = [
							"id": user.uid,
							"first_name": nsArray["first_name"] as! String,
							"last_name": nsArray["last_name"] as! String,
							"facebook_id": FBSDKAccessToken.current().userID!,
							"profile_picture": datum["url"] as! String,
							"nationality": "Argentina"
							// add location
						]
						itemRef.updateChildValues(userItem)
						
						NotificationCenter.default.post(name: Notification.Name(rawValue: registerUserKey), object: self, userInfo: nil)

						
					}
				}
			}
		};
		
	}

}
