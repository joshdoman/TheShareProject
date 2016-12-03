//
//  AcceptController2.swift
//  TheShareProject
//
//  Created by Josh Doman on 12/1/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class AcceptController: UIViewController {
    
    lazy var denyButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "Cancel-50")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleDeny), for: .touchUpInside)
        return button
    }()
    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "Checked-50")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        return button
    }()
    
    let topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    
    
    var messageController: MessagesController?
    var prevAcceptController: AcceptController?

    var requestId: String?
    
    var requestArray: [String]?
    
    var requestDictionary: [String: Request]?
    
    var myRequest: Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = .white
        
        requestArray = messageController?.requests
        requestDictionary = messageController?.requestDictionary
        myRequest = requestDictionary?[requestId!]
        
        setupController()
        
        attemptPopUp()
    }
    
    var timer: Timer?
    
    func attemptPopUp() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handlePopUp), userInfo: nil, repeats: false)
    }
    
    func handlePopUp() {
        popUpNextAcceptController()
    }
    
    func popUpNextAcceptController() {
        if !(messageController?.requests.isEmpty)! {
            let nextRequestId = messageController?.requests.first
            messageController?.requests.removeFirst()
            
            let acceptController = AcceptController()
            
            acceptController.messageController = messageController
            acceptController.requestId = nextRequestId
            
            acceptController.prevAcceptController = self
            present(acceptController, animated: true, completion: nil)
        }
    }
    
    func setupController() {
        view.addSubview(topBar)
        view.addSubview(denyButton)
        view.addSubview(acceptButton)
        
        _ = denyButton.anchor(view.centerYAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        denyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -80).isActive = true
        
        _ = acceptButton.anchor(view.centerYAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        acceptButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 80).isActive = true
        
        _ = topBar.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 100)
    }
    
    func handleAccept() {
        FIRDatabase.database().reference().child("acceptances").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(self.requestId!) {
                let alertController = UIAlertController(title: "Sorry someone is already rescuing this person", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { action -> Void in
                    self.handleOkay()
                }))
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.connectUsersAndShowMessages()
            }
            
        }, withCancel: nil)
    }
    
    func handleOkay() {
        dismiss(animated: true, completion: nil)
    }
    
    func connectUsersAndShowMessages() {
        guard let uid = AppManager.getCurrentUID() else {
            return
        }
        
        let acceptRef1 = FIRDatabase.database().reference().child("acceptances").child(requestId!)
        
        acceptRef1.updateChildValues([uid: 1])
        
        let acceptRef2 = FIRDatabase.database().reference().child("acceptances").child(uid)
        
        acceptRef2.updateChildValues([requestId!: 1])
        
        let ref = FIRDatabase.database().reference().child("users").child(requestId!)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = User()
            user.uid = self.requestId!
            user.setValuesForKeys(dictionary)
            self.segueToMessage(user: user)
        }, withCancel: nil)
    }
    
    func segueToMessage(user: User) {
        if prevAcceptController != nil {
            dismiss(animated: true, completion: {
                self.prevAcceptController?.segueToMessage(user: user)
            })
        } else {
            dismiss(animated: true, completion: {
                self.messageController?.showChatControllerForUser(user: user)
            })
        }
    }
    
    func handleDeny() {
        
        guard let uid = AppManager.getCurrentUID() else {
            return
        }
        
        FIRDatabase.database().reference().child("denials").child(uid).updateChildValues([requestId!: 1])
        FIRDatabase.database().reference().child("denials-sorted-by-request").child(requestId!).updateChildValues([uid: 1])
        
        dismiss(animated: true, completion: nil)
    }
    
}

