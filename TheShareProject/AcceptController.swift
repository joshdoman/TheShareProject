//
//  AcceptController.swift
//  TheShareProject
//
//  Created by Josh Doman on 11/17/16.
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

    
    var messageController: MessagesController?
    var request: Request?
    var requestId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(denyButton)
        view.addSubview(acceptButton)
        
        _ = denyButton.anchor(view.centerYAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        denyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -80).isActive = true
        
        _ = acceptButton.anchor(view.centerYAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        acceptButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 80).isActive = true
        
        
    }
    
    func handleAccept() {
        
        guard let uid = AppManager.getCurrentUID() else {
            return
        }
        
        let acceptRef = FIRDatabase.database().reference().child("acceptances").child(requestId!)
        
        acceptRef.updateChildValues([uid: 1])
        
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
        dismiss(animated: true, completion: {
            self.messageController?.showChatControllerForUser(user: user)
        })
    }
    
    
    func handleDeny() {
        _ = messageController?.requestDictionary.removeValue(forKey: requestId!)
        messageController?.requests.remove(at: (messageController?.requests.index(of: requestId!))!)
        messageController?.resetTimer()
        UserDefaults.standard.setIsHandlingRequest(value: false)
        dismiss(animated: true, completion: nil)
        //AppManager.handlingRequest = false    //makes pop back up
    }

}
