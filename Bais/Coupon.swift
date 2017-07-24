//
//  Coupon.swift
//  BAIS
//
//  Created by jonathan.bursztyn on 7/20/17.
//  Copyright © 2017 Board Social, Inc. All rights reserved.
//

import Foundation
import PromiseKit

class Coupon{
    var couponId = ""
    var redeemed = false
    var imageUrl = ""
    
    convenience init (from dictionary: NSDictionary){
        self.init()
        couponId = dictionary["coupon_id"] as! String
        redeemed = dictionary["redeemed"] as! Bool
    }
    
    func fetchAdditionalData() -> Promise<Void>{
        return Promise{ fulfill, reject in
            // should fetch additional data
            FirebaseService.couponsReference.child(couponId).observeSingleEvent(of: .value, with: { snapshot in
                guard let dictionary = snapshot.value as? NSDictionary else {
                    fulfill()
                    return
                }
                self.imageUrl = dictionary["image"] as! String
                fulfill()
            })
        }
    }
}
