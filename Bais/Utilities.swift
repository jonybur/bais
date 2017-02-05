//
//  Utilities.swift
//  Clubby
//
//  Created by Jonathan Bursztyn on 1/1/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import AsyncDisplayKit
import Foundation
import UIKit
import Foundation
import CoreGraphics
import CoreLocation

class ez {
	open static let screenWidth : CGFloat = UIScreen.main.bounds.width;
	open static let screenHeight : CGFloat = UIScreen.main.bounds.height;
}

extension UIFont{
	func sizeOfString(_ stringToMeasure: String) -> CGSize {
		return NSString(string: stringToMeasure).size(attributes: [NSFontAttributeName: self]);
	}
}

extension ClosedRange where Bound : FloatingPoint {
	public func random() -> Bound {
		let range = self.upperBound - self.lowerBound
		let randomValue = (Bound(arc4random_uniform(UINT32_MAX)) / Bound(UINT32_MAX)) * range + self.lowerBound
		return randomValue
	}
}

extension NSAttributedString {
	static func attributedString(string: String?, fontSize size: CGFloat, color: UIColor?) -> NSAttributedString? {
		guard let string = string else { return nil }
		
		let attributes = [NSForegroundColorAttributeName: color ?? UIColor.black,
		                  NSFontAttributeName: UIFont.boldSystemFont(ofSize: size)]
		
		let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
		
		return attributedString
	}
}

extension String {
	public func indexOfCharacter(_ char: Character) -> Int? {
		if let idx = self.characters.index(of: char) {
			return self.characters.distance(from: self.startIndex, to: idx)
		}
		return nil
	}
}

extension Date {
	func timeAgoSinceDate(_ numericDates:Bool) -> String {
		let calendar = Calendar.current
		let now = Date()
		let earliest = (now as NSDate).earlierDate(self)
		let latest = (earliest == now) ? self : now
		let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
		
		if (components.year! >= 2) {
			return "\(components.year!) years ago"
		} else if (components.year! >= 1){
			if (numericDates){
				return "1 year ago"
			} else {
				return "Last year"
			}
		} else if (components.month! >= 2) {
			return "\(components.month!) months ago"
		} else if (components.month! >= 1){
			if (numericDates){
				return "1 month ago"
			} else {
				return "Last month"
			}
		} else if (components.weekOfYear! >= 2) {
			return "\(components.weekOfYear!) weeks ago"
		} else if (components.weekOfYear! >= 1){
			if (numericDates){
				return "1 week ago"
			} else {
				return "Last week"
			}
		} else if (components.day! >= 2) {
			return "\(components.day!) days ago"
		} else if (components.day! >= 1){
			if (numericDates){
				return "1 day ago"
			} else {
				return "Yesterday"
			}
		} else if (components.hour! >= 2) {
			return "\(components.hour!) hours ago"
		} else if (components.hour! >= 1){
			if (numericDates){
				return "1 hour ago"
			} else {
				return "An hour ago"
			}
		} else if (components.minute! >= 2) {
			return "\(components.minute!) minutes ago"
		} else if (components.minute! >= 1){
			if (numericDates){
				return "1 minute ago"
			} else {
				return "A minute ago"
			}
		} else if (components.second! >= 3) {
			return "\(components.second!) seconds ago"
		} else {
			return "Just now"
		}
		
	}
}

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

extension CGRect{
	mutating func setNewFrameHeight(_ height: CGFloat) {
		self = CGRect(x: self.origin.x, y: self.origin.y, width: self.width, height: height);
	}
	
	init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
		self.init(x:x, y:y, width:w, height:h)
	}
}

extension CGPoint{
	init(_ x:CGFloat, _ y:CGFloat) {
		self.init(x:x, y:y)
	}
}

extension Int {
	var cgf: CGFloat { return CGFloat(self) }
	var f: Float { return Float(self) }
}

extension Float {
	var cgf: CGFloat { return CGFloat(self) }
}

extension Double {
	var cgf: CGFloat { return CGFloat(self) }
}

extension CGFloat {
	var f: Float { return Float(self) }
}

// TODO: move this inside imageModificationBlock, remove extension - avoid calling UIGraphicsBeginImageContextWithOptions again
extension UIImage {
	func tintedWithLinearGradientColors(colorsArr: [CGColor?]) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
		let context = UIGraphicsGetCurrentContext()
		context!.translateBy(x: 0, y: self.size.height)
		context!.scaleBy(x: 1.0, y: -1.0)
		
		context!.setBlendMode(CGBlendMode.normal)
		let rect = CGRect(0, 0, self.size.width, self.size.height)
		
		// Create gradient
		
		let colors = colorsArr as CFArray
		let space = CGColorSpaceCreateDeviceRGB()
		let gradient = CGGradient(colorsSpace: space, colors: colors, locations: nil)
		
		// Apply gradient
		
		context!.clip(to: rect, mask: self.cgImage!)
		context!.drawLinearGradient(gradient!, start: CGPoint(0, self.size.height / 2), end: CGPoint(0, self.size.height), options: CGGradientDrawingOptions(rawValue: 0))
		let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return gradientImage!
	}
}

