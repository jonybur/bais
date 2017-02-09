//
//  CloudController.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 18/7/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import PromiseKit
import CoreLocation
import FBSDKCoreKit

let instagramDownloadedKey = "com.baisapp.instagramDownloaded";

@objc protocol WebServiceDelegate: class {
	@objc optional func eventsLoaded(_ events: [Event])
	@objc optional func uberProductsLoaded(_ uberProducts: [UberProduct])
	@objc optional func gotRSVPStatus(of eventId: String, status: RSVPStatus)
}

// rename to WebService
class WebService{
	
	weak var delegate: WebServiceDelegate?
	let uberServerToken = "b_kEklxu3QSAD_ZigupALYGYzSWs-DDB132IrpcU"
	var uberProducts = [UberProduct]()
	
	func setNewRSVPStatus(_ eventId: String, rsvpStatus: RSVPStatus){
		
		let graphRequest = FBSDKGraphRequest(graphPath: eventId + "/" + String(describing: rsvpStatus),
		                                                        parameters: nil, httpMethod: "POST");
		
		graphRequest?.start { connection, result, error in
			// TODO: check if result is success = 1
			//returns rsvpStatus
		}.start()
		
	}
	
	func getRSVPStatus(of event: Event){
		getRSVPStatus(event.id, rsvpStatus: .attending)
	}
	
	private func getRSVPStatus(_ eventId: String, rsvpStatus: RSVPStatus) {
	
		let graphPath = eventId + "/" + String(describing: rsvpStatus) + "/" + FBSDKAccessToken.current().userID
		let graphRequest = FBSDKGraphRequest(graphPath: graphPath, parameters: nil);
		
		graphRequest?.start { connection, result, error in
			
			if error != nil {
				print("ERROR: " + error.debugDescription)
				return
			} else {
				if let nsArray = result as? NSDictionary {
					if let datum = nsArray.object(forKey: "data") as? NSArray{
						
						if (datum.count > 0){
							// accepted or maybe
							// make NSNotification, we have the events ready
							// returns rsvpStatus
							self.delegate?.gotRSVPStatus!(of: eventId, status: rsvpStatus)
							
						} else if (rsvpStatus != .declined) {
							self.getRSVPStatus(eventId, rsvpStatus: rsvpStatus.next());
							
						} else {
							// declined
							self.delegate?.gotRSVPStatus!(of: eventId, status: rsvpStatus)
						}
					}
				}
			}
		}.start()
	}
		
	// call from main thread
	func getFacebookEvents(){
		
		// gets events from facebook
		let graphRequest = FBSDKGraphRequest(graphPath: "baisinternationalstudents",
		                                     parameters: ["fields": "events{description,end_time,name,place,id,start_time,cover}"])
		
		graphRequest?.start { connection, result, error in
			if error != nil {
				print("ERROR: " + error.debugDescription)
				return
			} else {
				
				var eventsArray = [Event]();
				
				// TODO: change to guards
				if let nsArray = result as? NSDictionary {
					if let events = nsArray.object(forKey: "events") as? NSDictionary{
						if let datum = events.object(forKey: "data") as? NSArray{
							for data in datum{
								if let event = data as? NSDictionary{
									let parsedEvent = Event();
									parsedEvent.startTime = self.stringToNSDate(event["start_time"] as! String);
									parsedEvent.endTime = self.stringToNSDate(event["end_time"] as! String);
									parsedEvent.id = event["id"] as! String;
									parsedEvent.eventDescription = event["description"] as! String;
									parsedEvent.name = event["name"] as! String;
									
									// TODO: Also remove "I Bais Argentina"
									if let separatorChar = parsedEvent.name.indexOfCharacter("|") {
										let range = parsedEvent.name.startIndex..<parsedEvent.name.characters.index(parsedEvent.name.startIndex, offsetBy: separatorChar-1);
										parsedEvent.name = parsedEvent.name[range];
									}
									
									// change to guards
									if let place = event["place"] as? NSDictionary{
										parsedEvent.place.name = place["name"] as! String;
										
										if let location = place["location"] as? NSDictionary{
											if let street = location["street"] as? String{
												parsedEvent.place.street = street;
											}
											
											let coordinates : CLLocation = CLLocation(latitude: location["latitude"] as! Double,
												longitude: location["longitude"] as! Double);
											parsedEvent.place.coordinates = coordinates;
										}
									}
									
									if let cover = event["cover"] as? NSDictionary{
										parsedEvent.imageUrl = cover["source"] as! String;
									}
									
									eventsArray.append(parsedEvent);
								}
							}
						}
					}
				}
				
				eventsArray = eventsArray.sorted(by: {
					$0.startTime.compare($1.startTime as Date) == ComparisonResult.orderedAscending
				});

				self.delegate?.eventsLoaded!(eventsArray)
			}
		}.start()
	}
	
	func stringToNSDate(_ value: String) -> Date {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH:mm:ssZ"
		let date = dateFormatter.date(from: value)
		return date!
	}

	func getUberProducts(_ location: CLLocationCoordinate2D){
		if (self.uberProducts.count > 0){
			delegate?.uberProductsLoaded!(self.uberProducts)
			return
		}
		
		let urlString = "https://api.uber.com/v1/products?latitude=" + String(location.latitude) +
								"&longitude=" + String(location.longitude) + "&server_token=" + uberServerToken
		
		// gets uber products
		WebAPI.request(url: urlString).then { a -> Void in
			let jsonNSData = a
			let json = JSON(data: jsonNSData as Data)
			var uberProducts = [UberProduct]()
			
			for (_, subjson):(String, JSON) in json["products"]{
				let product = UberProduct()
				product.displayName = subjson["display_name"].stringValue
				product.productId = subjson["product_id"].stringValue
				uberProducts.append(product)
			}
			
			self.uberProducts = uberProducts
			self.delegate?.uberProductsLoaded!(self.uberProducts)
		}.catch { _ in }
		
	}
}
