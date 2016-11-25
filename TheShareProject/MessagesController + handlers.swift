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
                    if let username = user.name, let uid = user.uid, let number = user.number {
                        print("I need a " + needCharger + ". " + text)
                        let item = needCharger!
                        let location = text
                        
                        // Send POST request to /notify/all
                        
                        NetworkManager.sendChargerRequest(item: item, location: location, username: username, uid: uid, number: number)
                        
                        handleSegue(type: "request")
                        
                        AppManager.requesting = true;
                    }
                }
            }
        }
    }
    
    func handleCheckRequests() {
        //Send GET request to /info
        
        //TODO
        NetworkManager.areThereOutstandingRequests()
    }
    
    func handleGet()
    {
        if AppManager.handlingRequest! == false && AppManager.requesting! == false {
            handleCheckRequests()
            if MessagesController.requested! == true {
                AppManager.handlingRequest = true
                MessagesController.requested = false
                handleSegue(type: "accept") //go to new viewcontroller
            }
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
            
        } else if type == "request" {
            
            let requestController = RequestPendingViewController()
            let navController = UINavigationController(rootViewController: requestController)
            present(navController, animated: true, completion: nil)
            
        }
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
