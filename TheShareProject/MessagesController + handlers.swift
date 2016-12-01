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
                        
                        let values = ["name": name as AnyObject, "item": item as AnyObject, "timestamp": timestamp, "message": message as AnyObject] as [String : AnyObject]
                        
                        sendRequestToFirebase(uid: uid, values: values)
                        
                        NetworkManager.sendChargerRequestToServer(item: item, message: message, name: name, number: number)
                        
                        segueToPending()
                    }
                }
            }
        }
    }
    
    func handleShowMessage() {
        checkIfHandlingRequestThenCheckIfRequesting()
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
    
    func handleProfile() {
        let profileController = ProfileViewController()
        let navController = UINavigationController(rootViewController: profileController)
        present(navController, animated: true, completion: nil)
    }
    
    func openChatControllerWithPartner(uid: String) {
        FIRDatabase.database().reference().child("acceptances").child(uid).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            //print(snapshot.key)
            
            FIRDatabase.database().reference().child("users").child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User()
                    user.setValuesForKeys(dictionary)
                    user.uid = snapshot.key
                    self.showChatControllerForUser(user: user)
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func checkIfHandlingRequestThenCheckIfRequesting() {
        guard let uid = AppManager.getCurrentUID() else {
            return
        }
        
        FIRDatabase.database().reference().child("acceptances").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(uid) {
                print("someone has accepted")
                self.openChatControllerWithPartner(uid: uid)
            } else {
                self.checkIfUserIsRequestingOrIfSomeoneElseIsRequesting(uid: uid)
            }
            
        }, withCancel: nil)
    }
    
    func checkIfUserIsRequestingOrIfSomeoneElseIsRequesting(uid: String) {
        
        let ref = FIRDatabase.database().reference().child("requests")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(uid) {
                UserDefaults.standard.setIsRequesting(value: true)
                print("I am requesting")
                self.segueToPending()
            } else if snapshot.hasChildren() {
                print("there's a request out there")
                self.fetchRequestsFromFirebase()
            }
            
        }, withCancel: nil)
    }
    
    func pushAllAcceptControllers() {
        if !requests.isEmpty {
            let requestId = requests.first
            requests.removeFirst()
            
            let acceptController = AcceptController()
            
            acceptController.messageController = self
            acceptController.requestId = requestId
            
            print("present")
            present(acceptController, animated: true, completion: nil)
        }
    }
    
    //this version pops up one request at a time
    func fetchRequestsFromFirebase() {
        FIRDatabase.database().reference().child("requests").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let request = Request(dictionary: dictionary)
                request.fromId = snapshot.key
                self.requestDictionary[snapshot.key] = request
            }
            
            self.attemptToLoadRequests()
            
        }, withCancel: nil)
        
    }
    
    
    func removeDeniedRequest() {
        guard let uid = AppManager.getCurrentUID() else {
            return
        }
        
        FIRDatabase.database().reference().child("denials").child(uid).observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                for request in self.requests {
                    if dictionary[request] != nil, let index = self.requests.index(of: request) {
                        self.requests.remove(at: index)
                    }
                }
            }

            self.pushAllAcceptControllers()
            
        }, withCancel: nil)
        
    }
    
    func segueToPending() {
        let requestController = RequestPendingViewController()
        requestController.messagesController = self
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
    
    func attemptToLoadRequests() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleLoadRequests), userInfo: nil, repeats: false)
    }
    
    func handleLoadRequests() {
        self.requests = Array<String>(self.requestDictionary.keys)
        removeDeniedRequest()
    }
    
}
