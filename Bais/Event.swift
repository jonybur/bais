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
	var startTime : Date = Date();
	var endTime : Date = Date();
	var id : String = "";
	var description : String = "";
	var name : String = "";
	var place : Place = Place();
	var imageUrl : String = "";
	
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
