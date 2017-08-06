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
	
	static var currentUserId: String{
		get{
			guard let id = FIRAuth.auth()?.currentUser?.uid else { return "" }
			return id
		}
	}
	
	static let rootReference = FIRDatabase.database().reference()
	static let versionsReference = FIRDatabase.database().reference().child("versions").child("required_version")
	static let locationsReference = FIRDatabase.database().reference().child("locations")
	static let locationsHistoryReference = FIRDatabase.database().reference().child("locations_history")
	static let usersReference = FIRDatabase.database().reference().child("users")
    static let promotionsReference = FIRDatabase.database().reference().child("promotions")
    static let referenceIdsReference = FIRDatabase.database().reference().child("reference_ids")
    static let couponsReference = FIRDatabase.database().reference().child("coupons")
	static let sessionsReference = FIRDatabase.database().reference().child("sessions")
	static let reportsReference = FIRDatabase.database().reference().child("reports")
	static let feedbackReference = FIRDatabase.database().reference().child("feedback")
	#if DEVELOPMENT
	static let rootStorageReference = FIRStorage.storage().reference(forURL: "gs://bais-dev.appspot.com")
	static let serverKey = "***REMOVED***"
	#else
	static let rootStorageReference = FIRStorage.storage().reference(forURL: "gs://bais-79d67.appspot.com")
	static let serverKey = "***REMOVED***"
	#endif
	
	enum ImagePurpose: String{
		case profilePicture = "profile_picture"
	}
    
    static func setReferenceId(){
        FirebaseService.usersReference.child(currentUserId).child("reference_id").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot!) in
            // checks if referenceId exists
            guard let _ = snapshot.value as? String else {
                FirebaseService.createReferenceId()
                return
            }
        }
    }
    
    static func grantReferralCoupon(to userId: String){
        if (userId == currentUserId) {
            // reference id is for current user, do not grant coupon
            return
        }
        promotionsReference.child("on_referral").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot!) in
            // checks if promotion exists
            guard let couponId = snapshot.value as? String else { return }
            let coupon = ["coupon_id": couponId,
                          "redeemed": false] as [String : Any]
            let promotionId = "on_referral_" + userId
            usersReference.child(userId).child("coupons").child(promotionId).setValue(coupon)
            // notifies user
            self.getUser(with: userId).then(execute: { user -> Void in
                postPushNotification(to: user, body: "You just earned a coupon!", sound: true)
            }).catch(execute: { _ in })
        }
    }
    
    static func grantCoupon(for promotionId: String, to userId: String) {
        // fetches coupon
        promotionsReference.child(promotionId).observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot!) in
            // checks if promotion exists
            guard let couponId = snapshot.value as? String else { return }
            let coupon = ["coupon_id": couponId,
                          "redeemed": false] as [String : Any]
            usersReference.child(userId).child("coupons").child(promotionId).setValue(coupon)
        }
    }
    
    static func grantCoupon(for promotionId: String) {
        grantCoupon(for: promotionId, to: currentUserId)
    }
    
    static func createReferenceId() {
        let firstNameLetter = CurrentUser.user.firstName.characters.count > 0 ?
            CurrentUser.user.firstName.substring(to: 1) : ""
        let lastNameLetter = CurrentUser.user.lastName.characters.count > 0 ?
            CurrentUser.user.lastName.substring(to: 1) : ""

        let referenceId = firstNameLetter + lastNameLetter + String(ez.random(0..<9999))
        let value = [
            referenceId: currentUserId
        ]
        referenceIdsReference.updateChildValues(value)
        usersReference.child(currentUserId).child("reference_id").setValue(referenceId)
        CurrentUser.user.referenceId = referenceId
    }
    
	static func logOut(){
		resetUserNotificationToken()
		CurrentUser.user = nil
		CurrentUser.location = CLLocation()
		try! FIRAuth.auth()!.signOut()
	}
	
	static func sendFeedback(_ text: String){
		let value = [
			"user_id": currentUserId,
			"comments": text,
			"timestamp": FIRServerValue.timestamp()
			] as [String : Any]
		let reference = feedbackReference.childByAutoId()
		reference.updateChildValues(value)
	}
	
	static func sendReport(for user: User, reason: String){
		let value = [
			"user_id": user.id,
			"reported_by": currentUserId,
			"reason": reason,
			"timestamp": FIRServerValue.timestamp()
			] as [String : Any]
		let reference = reportsReference.childByAutoId()
		reference.updateChildValues(value)
	}
	
	static func sendMessage(_ message: Message, to session: Session) -> String{
		let value = [
			"sender_id": message.senderId,
			"text": message.text,
			"timestamp": FIRServerValue.timestamp()
			] as [String : Any]
		let reference = sessionsReference.child(session.id).child("messages").childByAutoId()
		reference.updateChildValues(value)
	
		for user in session.participants{
			if (user.id == currentUserId){
				continue
			}
			postPushNotification(to: user, title: CurrentUser.user.firstName, body: message.text, sound: true)
			addToUnreadCount(to: session, of: user)
		}
		
		return reference.key
	}
	
	static func resetUnreadCount(of session: Session){
		let userBadgeCountRef = usersReference.child(currentUserId).child("sessions").child(session.id).child("unread_count")
		userBadgeCountRef.runTransactionBlock { currentData -> FIRTransactionResult in
			currentData.value = 0
			return FIRTransactionResult.success(withValue: currentData)
		}
	}
	
	static func addToUnreadCount(to session: Session, of user: User){
		let unreadCountRef = usersReference.child(user.id).child("sessions").child(session.id).child("unread_count")
		unreadCountRef.runTransactionBlock { currentData -> FIRTransactionResult in
			guard let currentBadgeValue = currentData.value as? Int else { return FIRTransactionResult.success(withValue: currentData) }
			let newBadgeValue = currentBadgeValue + 1
			currentData.value = newBadgeValue
			return FIRTransactionResult.success(withValue: currentData)
		}
	}
	
	static func resetBadgeCount(){
		let userBadgeCountRef = usersReference.child(currentUserId).child("badge_count")
		userBadgeCountRef.runTransactionBlock { currentData -> FIRTransactionResult in
			currentData.value = 0
			return FIRTransactionResult.success(withValue: currentData)
		}
	}
	
	static func postPushNotification(to user: User, body: String, sound: Bool){
		postPushNotification(to: user, title: "", body: body, sound: sound)
	}
	
	static func postPushNotification(to user: User, title: String, body bodyString: String, sound: Bool){
		let userBadgeCountRef = usersReference.child(user.id).child("badge_count")
		
		// TODO: should run transaction block for notification token as well?
		userBadgeCountRef.runTransactionBlock { currentData -> FIRTransactionResult in
			
			guard let currentBadgeValue = currentData.value as? Int else { return FIRTransactionResult.success(withValue: currentData) }
			let newBadgeValue = currentBadgeValue + 1
			currentData.value = newBadgeValue
			
			// sends push notification
			let httpHeaders = [
				"Content-Type": "application/json",
				"Authorization": "key=" + FirebaseService.serverKey
			]
			
			var notification = [
				"body": bodyString,
				"badge": newBadgeValue
				] as [String : Any]
			
			if (title.characters.count > 0){
				notification.updateValue(title, forKey: "title")
			}
			
			if (sound){
				notification.updateValue("default", forKey: "sound")
			}
			
			let body = [
				"to": user.notificationToken,
				"notification": notification
				] as [String : Any]
			
			_ = WebAPI.postRequest(url: "https://fcm.googleapis.com/fcm/send", body: body, headers: httpHeaders)
			
			return FIRTransactionResult.success(withValue: currentData)
		}
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
		guard let relationshipAttributes = relationshipSnapshot.value as? NSDictionary else { return .noRelationship }
		guard let relationshipStatus = relationshipAttributes["status"] as? String else { return .noRelationship }
		guard let relationshipPostedBy = relationshipAttributes["posted_by"] as? String else { return .noRelationship }
		
		var status: FriendshipStatus = .noRelationship
		
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
				let user = User(from: snapshot)
				fulfill(user)
			})
		}
	}
	
	static func checkVersionUpdate() -> Promise<Bool>{
		return Promise { fulfill, reject in
			
			versionsReference.runTransactionBlock { currentData -> FIRTransactionResult in
				guard let requiredVersion = currentData.value as? String else {
					fulfill(false)
					return FIRTransactionResult.success(withValue: currentData) }
				
				let localVersion = Bundle.main.releaseVersionNumber!
				
				if (requiredVersion == localVersion){
					fulfill(false)
				}
				
				let updateIsRequired = !requiredVersion.versionToInt().lexicographicallyPrecedes(localVersion.versionToInt())
				fulfill(updateIsRequired)
				
				return FIRTransactionResult.success(withValue: currentData)
			}
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
			
			imagesRef.put(data!, metadata: nil) { metadata, error in
				if let error = error {
					print("ERROR: " + error.localizedDescription)
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
    
    static func updateUserPromoId(with promoId: String){
        usersReference.child(currentUserId).updateChildValues(["promo_id": promoId])
    }
	
	static func updateUserNationality(with country: String){
		usersReference.child(currentUserId).updateChildValues(["country_code": country])
	}
	
	static func resetUserNotificationToken(){
		if (currentUserId != ""){
			let userNotificationTokenRef = usersReference.child(currentUserId).child("notification_token")
			userNotificationTokenRef.runTransactionBlock { currentData -> FIRTransactionResult in
				currentData.value = ""
				return FIRTransactionResult.success(withValue: currentData)
			}
		}
	}
	
	static func updateUserNotificationToken(){
		guard let token = FIRInstanceID.instanceID().token() else { return }
		if (currentUserId != ""){
			let userNotificationTokenRef = usersReference.child(currentUserId).child("notification_token")
			userNotificationTokenRef.runTransactionBlock { currentData -> FIRTransactionResult in
				currentData.value = token
				return FIRTransactionResult.success(withValue: currentData)
			}
		}
	}
	
	static func updateUserLocation(_ location: CLLocationCoordinate2D){
		let geoFire = GeoFire(firebaseRef: locationsReference)
		
		let locationValue = [location.latitude, location.longitude]
		let value = ["location": locationValue]
		
		usersReference.child(currentUserId).updateChildValues(value)
		
		let historicValue = ["location": locationValue,
		                     "timestamp": FIRServerValue.timestamp()
							] as [String : Any]
		locationsHistoryReference.child(currentUserId).childByAutoId().updateChildValues(historicValue)
		
		geoFire?.setLocation(CLLocation(latitude: location.latitude, longitude: location.longitude), forKey: currentUserId)
		CurrentUser.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
	}
	
	static func getSessionByUser(_ userId: String) -> Promise<Session>{
		return Promise{ fulfill, reject in
			usersReference.child(currentUserId).child("sessions_by_user").child(userId).observeSingleEvent(of: .value, with: { snapshot in
				guard let sessionId = snapshot.value as? String else { return }
				
				self.getSession(from: sessionId).then(execute: { session -> Void in
					fulfill(session)
				}).catch(execute: { _ in })
			})
		}
	}
	
	static func endFriendRelationshipWith(friendId: String, sessionId: String){
		let selfRef = usersReference.child(currentUserId)
		let friendRef = usersReference.child(friendId)
		
		// kills relationship
		selfRef.child("friends").child(friendId).removeValue()
		friendRef.child("friends").child(currentUserId).removeValue()
		
		// deactivates chat session
		selfRef.child("sessions").child(sessionId).child("active").setValue(false)
		friendRef.child("sessions").child(sessionId).child("active").setValue(false)
	}
	
	static func denyFriendRequestFrom(friendId: String){
		let selfRef = usersReference.child(currentUserId).child("friends").child(friendId)
		selfRef.removeValue()
	}
	
	static func acceptFriendRequestFrom(friendId: String){
		setFriendStatusWith(friendId, to: .accepted)
		// create session
		let sessionId = startSessionWith(friendId)
		// add user-session to sessions_by_user
		addSessionsByUser(friendId, sessionId)
		
		getUser(with: friendId).then { user -> Void in
			let message = CurrentUser.user.firstName + " accepted your friend request"
			self.postPushNotification(to: user, body: message, sound: true)
		}.catch { error in }
	}
	
	static func addSessionsByUser(_ friendId: String, _ sessionId: String){
		let userValue = [
			friendId: sessionId
		]
		let friendValue = [
			currentUserId: sessionId
		]
		usersReference.child(currentUserId).child("sessions_by_user").updateChildValues(userValue)
		usersReference.child(friendId).child("sessions_by_user").updateChildValues(friendValue)
	}
	
	static func sendFriendRequestTo(friendId: String){
		setFriendStatusWith(friendId, to: .invitationSent)
		getUser(with: friendId).then { user -> Void in
			let message = CurrentUser.user.firstName + " sent you a friend request"
			postPushNotification(to: user, body: message, sound: false)
		}.catch { error in }
	}
	
	private static func startSessionWith(_ friendId: String) -> String{
		// create session on /sessions
		let users =
			[currentUserId: true,
			 friendId: true]
		let value = [
			"participants": users,
			"started": FIRServerValue.timestamp()
		] as [String : Any]
		let sessionRef = sessionsReference.childByAutoId()
		sessionRef.updateChildValues(value)
		
		let sessionAttributes = [
			"active": true,
			"unread_count": 0
		] as [String : Any]
		
		let sessionValue = [
			sessionRef.key: sessionAttributes
		] as [String : Any]
		
		usersReference.child(currentUserId).child("sessions").updateChildValues(sessionValue)
		usersReference.child(friendId).child("sessions").updateChildValues(sessionValue)
		
		return sessionRef.key
	}
	
	private static func setFriendStatusWith(_ friendId: String, to status: FriendshipStatus){
		var value = [String : String]()
		
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
													parameters: ["fields": "picture.width(400),first_name,last_name,birthday,email"],
													httpMethod: "GET")
			
			_ = graphRequest?.start (completionHandler: { connection, result, error in
				if error != nil {
					print("ERROR: " + error.debugDescription)
					return
				}
				
				guard let graphResult = result as? NSDictionary else { return }
				guard let events = graphResult.object(forKey: "picture") as? NSDictionary else { return }
				guard let datum = events["data"] as? NSDictionary else { return }
				guard let fbSDKAccessToken = FBSDKAccessToken.current().userID else { return }
				
				// OK, we have all facebook information now,
				// lets download the users profile picture from Facebook
                guard let profilePictureUrl = datum["url"] as? String else { return }
                
				WebAPI.request(url: profilePictureUrl).then(execute: { pictureData -> Void in
					// cool, now let's upload it to Firebase
					FirebaseService.storeImage(pictureData, as: .profilePicture).then(execute: { url -> Void in
						// we have the firebase-stored url!, lets finish pushing our user
						let messageRef = usersReference
						let itemRef = messageRef.child(user.uid)
                        
                        guard let firstName = graphResult["first_name"] as? String else { return }
                        guard let lastName = graphResult["last_name"] as? String else { return }
                        guard let birthday = graphResult["birthday"] as? String else { return }
                        guard let email = graphResult["email"] as? String else { return }
						
						let userItem = [
							"first_name": firstName,
							"last_name": lastName,
							"facebook_id": fbSDKAccessToken,
							"profile_picture": url.absoluteString,
							"birthday": birthday,
							"email": email,
							"country_code": "",
							"about": "",
							"registered": FIRServerValue.timestamp(),
							"badge_count": 0
						] as [String : Any]
						itemRef.updateChildValues(userItem)
						fulfill()
					}).catch(execute: { _ in })
				}).catch(execute: { _ in })
			})
		}
	}

}
