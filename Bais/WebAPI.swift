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
import PromiseKit

class WebAPI{
	
	static func postRequest(url: String, body: [String : Any], headers: [String: String]) -> Promise<Data>{
		return Promise{ resolve, reject in
			Alamofire.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
				.responseJSON(completionHandler: { response in
					resolve(response.data!)
			})
		}
	}
	
	static func requestJSON(url: String) -> Promise<Data> {
		return Promise{ resolve, reject in
			Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
				.responseJSON { response in
					resolve(response.data!)
			}
			
		}
	}
	
	static func request(url: String) -> Promise<Data>{
		return Promise{ fulfill, reject in
			Alamofire.request(url).responseData { response in
				if let data = response.result.value {
					fulfill(data)
				}
			}
		}
	}
	
}
