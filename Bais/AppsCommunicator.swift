//
//  AppCommunicator.swift
//  BAIS
//
//  Created by Jonathan Bursztyn on 8/9/16.
//  Copyright © 2016 Bais. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class AppsCommunicator{

	static func canOpenPhone()->Bool{
		return canOpenGeneric ("telprompt://");
	}
	
	static func canOpenInstagram()->Bool{
		return canOpenGeneric ("instagram://");
	}
	
	static func canOpenUber()->Bool{
		return canOpenGeneric ("uber://");
	}
	
	static func canOpenWaze()->Bool{
		return canOpenGeneric ("waze://");
	}
	
	static func canOpenGoogleMaps()->Bool{
		return canOpenGeneric ("comgooglemaps://");
	}
	
	static func canOpenFacebookMessenger()->Bool{
		return canOpenGeneric ("fb-messenger://");
	}
	
	fileprivate static func canOpenGeneric(_ link : String) ->Bool{
		let url : URL = URL (string: link)!;
		return UIApplication.shared.canOpenURL(url);
	}
	
	static func openFacebookMessenger(_ recieverId : String){
		let url : URL = URL (string: "fb-messenger://user-thread/"+recieverId)!;
		UIApplication.shared.openURL (url);
		
		// funciona?
		// UIApplication.shared.open(url, options: ["": ""], completionHandler: nil);
	}
	
	static func openUber(_ productId : String, dropoff : CLLocationCoordinate2D){
		
		let requestString : String = "uber://?client_id=7-UVBjdHfUrKKeZU9nDlP_HktFs3iWVT&product_id=" + productId + "&action=setPickup&pickup=my_location&dropoff[latitude]=" + String(dropoff.latitude) +
			"&dropoff[longitude]=" + String(dropoff.longitude);
		
		let uberRequest : URL = URL(string: requestString)!;
	
		UIApplication.shared.openURL(uberRequest);
	}

	static func openWaze(_ destination: CLLocationCoordinate2D){
		let wazeRequest : URL = URL(string: "waze://?ll="+String(destination.latitude)+","+String(destination.longitude)+"&z=10&navigate=yes")!;
		UIApplication.shared.openURL(wazeRequest);
	}
	
	static func openFacebook(_ facebookId : String, opensInApp : Bool){
		var url : URL;
		
		if (opensInApp) {
			// opens in app
			url = URL(string: "https://www.facebook.com/" + facebookId)!;
		} else {
			// opens in safari
			url = URL(string: "https://facebook.com/" + facebookId)!;
		}
		
		UIApplication.shared.openURL(url);
	}
	
	static func openInstagram(_ userName : String){
		let url : URL = URL(string: "instagram://user?username="+userName)!;
		UIApplication.shared.openURL(url);
	}
	
	static func openGoogleMaps(_ destination : CLLocationCoordinate2D){
		let url : URL = URL(string:"comgooglemaps://?&daddr="+String(destination.latitude)+","+String(destination.longitude)+"&directionsmode=driving")!;
		UIApplication.shared.openURL(url);
	}

	static func openAppleMaps(_ destination : CLLocationCoordinate2D){
		let url : URL = URL (string: "http://maps.apple.com/?daddr="+String(destination.latitude)+","+String(destination.longitude)+"&dirflg=d&t=m")!;
		UIApplication.shared.openURL(url);
	}
	
	static func openPhone(_ phoneNumber : String){
		let url : URL = URL (string: "telprompt://" + String(phoneNumber))!;
		UIApplication.shared.openURL(url);
	}

	static func openWebsite(_ websiteUrl : String){
		let url : URL = URL (string: websiteUrl)!;
		UIApplication.shared.openURL(url);
	}
}
