//
//  RequestPendingViewController.swift
//  TheShareProject
//
//  Created by Alessandro Portela on 11/18/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class RequestPendingViewController: UIViewController {

    @IBOutlet weak var pendingLabel: UILabel!
    
    var myTimer: Timer!
    var messagesController: MessagesController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupController()
        
        setupLabels()
        // Do any additional setup after loading the view.
        
        myTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(handleGetAcceptances), userInfo: nil, repeats: true)
    }
    
    func handleGetAcceptances() {
        guard let uid = AppManager.getCurrentUID() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("acceptances").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            print(snapshot.key)
            
            self.handleAccept(acceptId: snapshot.key)
            
        }, withCancel: nil)
    }
    
    func handleAccept(acceptId: String) {
        myTimer.invalidate()
        let ref = FIRDatabase.database().reference().child("users").child(acceptId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = User()
            user.uid = acceptId
            user.setValuesForKeys(dictionary)
            self.segueToMessage(user: user)
            
        }, withCancel: nil)
    }
    
    func segueToMessage(user: User) {
        dismiss(animated: true, completion: {
            self.messagesController?.showChatControllerForUser(user: user)
        })
    }
    
    func setupLabels() {
        //TODO-- maybe don't need
        
    }
    
    func setupController() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
    }
    
    func handleBack() {
        dismiss(animated: true, completion: nil)
    }
}
