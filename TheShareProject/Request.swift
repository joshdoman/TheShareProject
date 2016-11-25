//
//  Request.swift
//  TheShareProject
//
//  Created by Josh Doman on 11/25/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class Request: NSObject {
    
    var requestId: String?
    var fromId: String?
    var location: String?
    var timestamp: NSNumber?
    var item: String?
    var name: String?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        name = dictionary["name"] as? String
        location = dictionary["location"] as? String
        item = dictionary["item"] as? String
        
    }
    
}
