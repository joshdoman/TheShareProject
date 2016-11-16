//
//  ViewController.swift
//  gameofchats
//
//  Created by Josh Doman on 11/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UIViewController {
    
    lazy var getHelpButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 110, g: 151, b: 261)
        button.setTitle("Help", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleGetHelp), for: .touchUpInside)
        
        return button
    }()
    
    func handleGetHelp() {
        if let text = textMessage.text {
            if text == "" {
              print("Where are you?")
            } else {
              print(text)
            }
        } else {
            print("Say something!")
        }
    }
    
    let textMessage: UITextField = {
        let text = UITextField()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.placeholder = "Help! I'm in..."
        return text
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupController()
        
        checkIfUserIsLoggedIn()
        
    }
    
    func setupController() {
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(getHelpButton)
        view.addSubview(textMessage)
        
        setupGetHelpButton()
        setupTextMessage()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "Create New-50")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        // user is not loggen in
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                print(snapshot)
                                if let dictionary = snapshot.value as? [String: AnyObject] {
                                    self.navigationItem.title = dictionary["name"] as? String
                                }
                
            }, withCancel: nil)
        }
    }
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    func setupGetHelpButton() {
        //need x, y, height constraints
        getHelpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        getHelpButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        getHelpButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        getHelpButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupTextMessage() {
        //need x, y, height constraints
        textMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textMessage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50).isActive = true
        textMessage.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        textMessage.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
}

