//
//  AppManager.swift
//  TheShareProject
//
//  Created by Josh Doman on 11/20/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class AppManager: NSObject {

    static var handlingRequest: Bool?
    static var requesting: Bool?
    
    static func getCurrentUID() -> String? {
        return FIRAuth.auth()?.currentUser?.uid 
    }
    
    static var currentUser: User?
    
    static var requestDictionary: [String: Request]?
    
}
