//
//  File.swift
//  TheShareProject
//
//  Created by Josh Doman on 11/20/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import Foundation

struct User {
    
    let uid: String
    let email: String
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}
