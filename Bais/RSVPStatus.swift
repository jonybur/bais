//
//  RSVPStatus.swift
//  BAIS
//
//  Created by Jonathan Bursztyn on 2/9/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation

@objc enum RSVPStatus: Int{
	case attending = 0, maybe = 1, declined = 2, undefined = 3
	
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
