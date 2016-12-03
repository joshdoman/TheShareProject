//
//  NetworkManager.swift
//  TheShareProject
//
//  Created by Josh Doman on 11/22/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class NetworkManager {
    
    static func sendChargerRequestToServer(item: String, message: String, name: String, number: String) {
        
        
        let url = URL(string: "http://localhost:3000/notify/all")
        
        let request = NSMutableURLRequest(url: url!)
        
        request.httpMethod = "POST"
        do {
            let params = ["item":item, "message": message,"name": name, "number":number]
            
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                //
                if let error = error {
                    print(error.localizedDescription)
                    
                    
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        
                    }
                }
                
            })
            
            task.resume()
            
        } catch {
            
        }
    }
    
    static func sendConfirmation(user: User) {
        
        let url = URL(string: "http://localhost:3000/notify/user")
        
        let request = NSMutableURLRequest(url: url!)
        
        request.httpMethod = "POST"
        do {
            let params = ["name": AppManager.currentUser?.name, "number": user.number]
            
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                //
                if let error = error {
                    print(error.localizedDescription)
                    
                    
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        
                    }
                }
                
            })
            
            task.resume()
            
        } catch {
            
        }
    }
    
    static func getOutstandingRequest() {
        let url = URL(string: "http://localhost:3000/getRequestInfo")
        
        let request = NSMutableURLRequest(url: url!)
        
        request.httpMethod = "GET"
        do {
            //let params = ["item":item, "location":location,"username":username]
            
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            //request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
                //
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                    }
                }
                
                let resultNSString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                if resultNSString != "null" {
                    if let json = try! JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        print(json)
                        print(json["item"]!)
                    }
                } else {
                    print("handle Null")
                }
                
            })
            task.resume()
        }
    }
    
    
//    //This function sends a get request to the server, getting back a list of all users who are currently requesting a charger and a boolean indicating if there are any users requesting or not.
//    static func areThereOutstandingRequests() {
//        let url = URL(string: "http://localhost:3000/info")
//        
//        let request = NSMutableURLRequest(url: url!)
//        
//        request.httpMethod = "GET"
//        do {
//            //let params = ["item":item, "location":location,"username":username]
//            
//            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//            
//            //request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
//            
//            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
//                //
//                if let error = error {
//                    print(error.localizedDescription)
//                } else if let httpResponse = response as? HTTPURLResponse {
//                    if httpResponse.statusCode == 200 {
//                    }
//                }
//                //                let json = try! JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
//                ////                print("Here is the server response data!\n")
//                //                    print(json)
//                let resultNSString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
//                if resultNSString != "" {
//                    print(resultNSString)
//                    MessagesController.requested = true;
//                } else {
//                    //do nothing
//                    //TODO-- potential security vulnerability with checking for ""-- ask Yagil
//                }
//            })
//            task.resume()
//        }
//    }
    
    
}
