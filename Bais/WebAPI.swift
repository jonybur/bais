//
//  WebAPI.swift
//  Claxon
//
//  Created by Jonathan Bursztyn on 18/7/16.
//  Copyright © 2016 Claxon. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import AwaitKit
import PromiseKit

class WebAPI{
    
    static func request(url: String) -> Promise<Data> {
        return Promise{ resolve, reject in
			
			Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
				.responseJSON { response in
					resolve(response.data!);
			}
			
        }
    }
    
}
