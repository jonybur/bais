//
//  FirebaseService.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 26/9/16.
//  Copyright © 2016 Board Social, Inc. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FBSDKCoreKit
import CoreLocation
import PromiseKit
import GeoFire

class FirebaseService{
	
	static let currentUserId = (FIRAuth.auth()?.currentUser?.uid)!
	static let rootReference = FIRDatabase.database().reference()
	static let locationsReference = FIRDatabase.database().reference().child("locations")
	static let usersReference = FIRDatabase.database().reference().child("users")
	static let sessionsReference = FIRDatabase.database().reference().child("sessions")
	static let messagesReference = FIRDatabase.database().reference().child("messages")
	static let rootStorageReference = FIRStorage.storage().reference(forURL: "gs://bais-79d67.appspot.com")
	
	enum ImagePurpose: String{
		case profilePicture = "profile_picture"
	}
	
	static func getUserFromRelationship(from relationshipSnapshot: FIRDataSnapshot) -> Promise<User>{
		let status = parseFriendStatus(from: relationshipSnapshot)
		return Promise{ fulfill, reject in
			let friendId = String(describing: relationshipSnapshot.key)
			FirebaseService.getUser(with: friendId).then(execute: { user -> Void in
				// get user
				user.friendshipStatus = status
				fulfill(user)
			}).catch(execute: { _ in })
		}
	}
	
	static func parseFriendStatus(from relationshipSnapshot: FIRDataSnapshot) -> FriendshipStatus{
		guard let relationshipAttributes = relationshipSnapshot.value as? NSDictionary else { return .undefined }
		
		let relationshipStatus = relationshipAttributes["status"] as! String
		let relationshipPostedBy = relationshipAttributes["posted_by"] as! String
		var status: FriendshipStatus = .undefined
		
		if (relationshipStatus == "invited"){
			if (relationshipPostedBy == FirebaseService.currentUserId){
				status = .invitationSent
			} else {
				status = .invitationReceived
			}
		} else if (relationshipStatus == "accepted"){
			status = .accepted
		}
		
		return status
	}
	
	static func getSession(from id: String) -> Promise<Session>{
		return Promise{ fulfill, reject in
			sessionsReference.child(id).observe(.value, with: { snapshot in
				let session = Session(from: snapshot)
				// fulfill after all users get fetched
				session.loadParticipants(from: snapshot).then(execute: { void -> Void in
					fulfill(session)
				}).catch(execute: { _ in })
			})
		}
	}

	static func getUser(with userID: String) -> Promise<User>{
		return Promise{ fulfill, reject in
			usersReference.child(userID).observeSingleEvent(of: .value, with: { snapshot in
				let user = User(fromSnapshot: snapshot)
				fulfill(user)
			})
		}
	}
	
	static func getCurrentUser() -> Promise<User>{
		return Promise{ fulfill, reject in
			getUser(with: currentUserId).then(execute: { user -> Void in
				CurrentUser.user = user
				fulfill(user)
			}).catch(execute: { _ in })
		}
	}
	
	static func storeImage(_ data: Data, as imagePurpose: ImagePurpose) -> Promise<URL>{
		return storeImage(UIImage(data:data)!, as: imagePurpose)
	}
	
	static func storeImage(_ image: UIImage, as imagePurpose: ImagePurpose) -> Promise<URL>{
		return Promise{ fulfill, reject in
			let data = UIImageJPEGRepresentation(image, 0.75) as Data?
			let imagesRef = rootStorageReference.child(currentUserId).child(imagePurpose.rawValue + ".jpg")
			
			// Upload the file to the path "images/rivers.jpg"
			imagesRef.put(data!, metadata: nil) { metadata, error in
				if let error = error {
					reject(error)
				} else {
					fulfill(metadata!.downloadURL()!)
				}
			}
		}
	}
	
	static func updateUserImage(with url: String, imagePurpose: ImagePurpose){
		usersReference.child(currentUserId).updateChildValues([imagePurpose.rawValue: url])
	}
	
	static func updateUserAbout(with about: String){
		usersReference.child(currentUserId).updateChildValues(["about": about])
	}
	
	static func updateUserNationality(with country: String){
		usersReference.child(currentUserId).updateChildValues(["country_code": country])
	}
	
	static func updateUserLocation(_ location: CLLocationCoordinate2D){
		let geoFire = GeoFire(firebaseRef: locationsReference)
		
		let locationValue = [location.latitude, location.longitude]
		let value = ["location": locationValue]
		
		usersReference.child(currentUserId).updateChildValues(value)
		
		geoFire?.setLocation(CLLocation(latitude: location.latitude, longitude: location.longitude), forKey: currentUserId)
		CurrentUser.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
	}
	
	static func endFriendRelationshipWith(friendId: String){
		let selfRef = usersReference.child(currentUserId).child("friends").child(friendId)
		let friendRef = usersReference.child(friendId).child("friends").child(currentUserId)
	
		selfRef.removeValue()
		friendRef.removeValue()
	}
	
	static func denyFriendRequestFrom(friendId: String){
		let selfRef = usersReference.child(currentUserId).child("friends").child(friendId)
		selfRef.removeValue()
	}
	
	static func acceptFriendRequestFrom(friendId: String){
		setFriendStatusWith(friendId, to: .accepted)
		// create session
		startSessionWith(friendId)
	}
	
	static func sendFriendRequestTo(friendId: String){
		setFriendStatusWith(friendId, to: .invitationSent)
	}
	
	private static func startSessionWith(_ friendId: String){
		// create session on /sessions
		let users =
			[currentUserId: true,
			 friendId: true]
		let value = [
			"participants": users
		] as [String : Any]
		let selfRef = sessionsReference.childByAutoId()
		selfRef.updateChildValues(value)
		
		let sessionValue = [
			selfRef.key: true
		]
		usersReference.child(currentUserId).child("sessions").updateChildValues(sessionValue)
		usersReference.child(friendId).child("sessions").updateChildValues(sessionValue)

	}
	
	private static func setFriendStatusWith(_ friendId: String, to status: FriendshipStatus){
		var value = [String:String]()
		
		switch (status){
		case .accepted:
			value = [
				"status": status.rawValue
			]
			break
		case .invitationSent:
			value = [
				"status": "invited",
				"posted_by": currentUserId
			]
			break
		default: break
		}
		
		let selfRef = usersReference.child(currentUserId).child("friends").child(friendId)
		selfRef.updateChildValues(value)
		
		let friendRef = usersReference.child(friendId).child("friends").child(currentUserId)
		friendRef.updateChildValues(value)
	}
	
	// takes Firebase user, adds Facebook information, posts to database
	static func registerUser(_ user: FIRUser) -> Promise<Void> {
		
		return Promise{ fulfill, reject in

			if FBSDKAccessToken.current() == nil { return }
			
			let graphRequest = FBSDKGraphRequest(graphPath: "me",
													parameters: ["fields": "picture.width(400),first_name,last_name,birthday"],
													httpMethod: "GET")
			
			graphRequest?.start { connection, result, error in
				if error != nil {
					print("ERROR: " + error.debugDescription)
					return
				}
				
				if let nsArray = result as? NSDictionary {
					if let events = nsArray.object(forKey: "picture") as? NSDictionary{
						if let datum = events["data"] as? NSDictionary{
						
							// OK, we have all facebook information now,
							// lets download the users profile picture from Facebook
							let profilePictureUrl = datum["url"] as! String
							WebAPI.request(url: profilePictureUrl).then(execute: { pictureData -> Void in
								// cool, now let's upload it to Firebase
								FirebaseService.storeImage(pictureData, as: .profilePicture).then(execute: { url -> Void in
									// we have the firebase-stored url!, lets finish pushing our user
									let messageRef = usersReference
									let itemRef = messageRef.child(user.uid)
									let userItem = [
										"id": user.uid,
										"first_name": nsArray["first_name"] as! String,
										"last_name": nsArray["last_name"] as! String,
										"facebook_id": FBSDKAccessToken.current().userID!,
										"profile_picture": url.absoluteString,
										"birthday": "16/06/1993",//nsArray["birthday"] as! String,
										"country_code": "",
										"about": ""
									]
									itemRef.updateChildValues(userItem)
									fulfill()
								}).catch(execute: { _ in })
							}).catch(execute: { _ in })
							
						}
					}
				}
			}.start()
			
		}
	}

}
