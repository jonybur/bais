//
//  Picture.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 25/7/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import CoreLocation

class Event{
	
	var id = ""
	var description = ""
	var name = ""
	var imageUrl = ""
	var startTime = Date()
	var endTime = Date()
	var place = Place()
	var status: RSVPStatus = .undefined
	
	func redactedDate() -> String{
	
		let calendar = Calendar.current
		let startDateComponents = (calendar as NSCalendar).components([.day, .month], from: startTime as Date)
		let endDateComponents = (calendar as NSCalendar).components([.day, .month], from: endTime as Date)
		
		var dateString = ""
		
		if (startDateComponents.day != endDateComponents.day){
			// September 30 - October 4
			let startDateFormatter = DateFormatter()
			startDateFormatter.dateFormat = "MMMM d '-' "
			let startDateString = startDateFormatter.string(from: startTime as Date)
			
			let endDateFormatter = DateFormatter()
			endDateFormatter.dateFormat = "MMMM d"
			let endDateString = endDateFormatter.string(from: endTime as Date)
			
			dateString = startDateString + endDateString
			
		} else {
			// Saturday, September 14 at 3:00 PM - 4:00 PM
			let startDateFormatter = DateFormatter()
			startDateFormatter.dateFormat = "EEEE',' MMMM d 'at' h:mm a '-' "
			let startDateString = startDateFormatter.string(from: startTime as Date)
			
			let endDateFormatter = DateFormatter()
			endDateFormatter.dateFormat = "h:mm a"
			let endDateString = endDateFormatter.string(from: endTime as Date)
			
			dateString = startDateString + endDateString
		}
		
		return dateString
	}
	
	/*
	keys:
	
	start_time
	end_time
	id
	description
	name
	place
	cover
	*/
}
