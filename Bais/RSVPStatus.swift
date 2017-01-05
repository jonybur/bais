//
//  RSVPStatus.swift
//  BAIS
//
//  Created by Jonathan Bursztyn on 2/9/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation

enum RSVPStatus : String{
	case Attending = "attending", Maybe = "maybe", Declined = "declined"
	
	func next() -> RSVPStatus {
		switch self {
		case .Attending:
			return .Maybe;
		case .Maybe:
			return .Declined;
		default:
			return .Declined;
		}
	}
}
