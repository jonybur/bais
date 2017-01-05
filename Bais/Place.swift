//
//  Picture.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 25/7/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import CoreLocation

class Place{
	var name : String = "";
	var street : String = "";
	var coordinates : CLLocation = CLLocation();
	
	func isValid()->Bool{
		if (self.coordinates.coordinate.longitude == 0 &&
			self.coordinates.coordinate.latitude == 0){
			return false;
		}
		return true;
	}
}
