//
//  UIFont+Claxon.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 3/8/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import UIKit

extension UIFont{
    func sizeOfString(_ stringToMeasure: String) -> CGSize {
        return NSString(string: stringToMeasure).size(attributes: [NSFontAttributeName: self]);
    }
}
