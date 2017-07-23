//
//  Coupon.swift
//  BAIS
//
//  Created by jonathan.bursztyn on 7/20/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation

class Coupon{
    var image = ""
    var promotionId = ""
    var couponId: String?
    var redeemed: Bool?
    
    convenience init (from dictionary: NSDictionary){
        self.init()
        couponId = dictionary["coupon_id"] as? String
        redeemed = dictionary["redeemed"] as? Bool
        print("hola")
    }
}
