//
//  CLLocationDistance+Bais.swift
//  Bais
//
//  Created by Jonathan Bursztyn on 6/10/16.
//  Copyright © 2016 Board Social, Inc. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationDistance{

	func redacted() -> String{
		
		let kilometerDistance = self / 1000;
		
		let roundedDistance = Double((10 * kilometerDistance).rounded()/10);
		
		if (roundedDistance <= 0.3){
			
			// less than 300 m away
			return "Less than 300 m away";
			
		} else {
		
			let finalDistance = String(format: roundedDistance == floor(roundedDistance) ? "%.0f" : "%.1f", roundedDistance);

			// remove .0 at the end
			return finalDistance + " km away";
			
		}
	
	}
	
}
