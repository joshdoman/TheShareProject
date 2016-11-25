//
//  MessagesController + handlers.swift
//  TheShareProject
//
//  Created by Josh Doman on 11/23/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

extension MessagesController {
    
    func handleGetHelp() {
        if let text = textMessage.text {
            if text == "" {
                print("Where are you?")
            } else {
                
                if let user = AppManager.currentUser {
                    
                    if let name = user.name, let uid = user.uid, let number = user.number {
                        let item = needCharger!
                        let message = text
                        let timestamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
                        
                        let values = ["name": name as AnyObject, "item": item as AnyObject, "number": number as AnyObject, "timestamp": timestamp, "message": message as AnyObject] as [String : AnyObject]
                        
                        sendRequestToFirebase(uid: uid, values: values)
                        
                        NetworkManager.sendChargerRequestToServer(item: item, message: message, name: name, number: number)
                        
                        UserDefaults.standard.setIsHandlingRequest(value: true)
                        segueToPending()
                    }
                    
                }
                
//                if let user = AppManager.currentUser {
//                    if let username = user.name, let uid = user.uid, let number = user.number {
//                        print("I need a " + needCharger + ". " + text)
//                        let item = needCharger!
//                        let location = text
//                        //let timestamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
//                        
//                        // Send POST request to /notify/all
//                        
//                        NetworkManager.sendChargerRequest(item: item, location: location, username: username, uid: uid, number: number)
//                        
//                        handleSegue(type: "request")
//                        
//                        UserDefaults.standard.setIsHandlingRequest(value: true)
//                    }
//                }
            }
        }
    }
    
    func sendRequestToFirebase(uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference().child("requests").child(uid)
        ref.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                return
            }
        
        
        })
        
    }
    
    func handleGet()
    {
        if !requests.isEmpty && !UserDefaults.standard.isHandlingRequest() && !UserDefaults.standard.isRequesting() {
            UserDefaults.standard.setIsHandlingRequest(value: true)
            let requestId = requests.first
            let request = requestDictionary[requestId!]
            let acceptController = AcceptController()
            acceptController.requestId = requestId
            acceptController.request = request
            acceptController.messageController = self
            present(acceptController, animated: true, completion: nil)
        }
    }
    
    func handleProfile() {
        handleSegue(type: "profile")
    }
    
    func handleSegue(type: String) {
        if type == "profile" {
            
            let profileController = ProfileViewController()
            let navController = UINavigationController(rootViewController: profileController)
            present(navController, animated: true, completion: nil)
            
        } else if type == "accept" {
            
            let acceptController = AcceptController()
            //let navController = UINavigationController(rootViewController: acceptController)
            present(acceptController, animated: true, completion: nil)
            
        }
    }
    
    func segueToPending() {
        let requestController = RequestPendingViewController()
        let navController = UINavigationController(rootViewController: requestController)
        present(navController, animated: true, completion: nil)
    }
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
    
}
