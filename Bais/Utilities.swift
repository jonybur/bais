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
    
    open static func random(_ range:Range<Int>) -> Int {
        return range.lowerBound + Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound)))
    }
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
	
	func versionToInt() -> [Int] {
		return self.components(separatedBy: ".")
			.map { Int.init($0) ?? 0 }
	}
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }

}

extension Date {
	/// Returns the amount of years from another date
	func years(from date: Date) -> Int {
		return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
	}
	/// Returns the amount of months from another date
	func months(from date: Date) -> Int {
		return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
	}
	/// Returns the amount of weeks from another date
	func weeks(from date: Date) -> Int {
		return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
	}
	/// Returns the amount of days from another date
	func days(from date: Date) -> Int {
		return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
	}
	/// Returns the amount of hours from another date
	func hours(from date: Date) -> Int {
		return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
	}
	/// Returns the amount of minutes from another date
	func minutes(from date: Date) -> Int {
		return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
	}
	/// Returns the amount of seconds from another date
	func seconds(from date: Date) -> Int {
		return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
	}
	/// Returns the a custom time interval description from another date
	func offset(from date: Date) -> String {
		if years(from: date)   > 0 { return "\(years(from: date))y"   }
		if months(from: date)  > 0 { return "\(months(from: date))M"  }
		if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
		if days(from: date)    > 0 { return "\(days(from: date))d"    }
		if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
		if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
		if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
		return ""
	}
	
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
			return "Less than 300m away";
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

extension Bundle {
	var releaseVersionNumber: String? {
		return infoDictionary?["CFBundleShortVersionString"] as? String
	}
	var buildVersionNumber: String? {
		return infoDictionary?["CFBundleVersion"] as? String
	}
}
