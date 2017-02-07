//
//  RSVPStatus.swift
//  BAIS
//
//  Created by Jonathan Bursztyn on 2/9/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation

enum RSVPStatus: String{
	case attending = "attending", maybe = "maybe", declined = "declined", undefined = "undefined"
	
	func next() -> RSVPStatus {
		switch self {
		case .attending:
			return .maybe;
		case .maybe:
			return .declined;
		default:
			return .declined;
		}
	}
}
