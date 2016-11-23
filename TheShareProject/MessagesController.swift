
//
//  ViewController.swift
//  gameofchats
//
//  Created by Josh Doman on 11/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

import CoreFoundation
import CoreGraphics
import Darwin
import Darwin.uuid
import Foundation

class MessagesController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var needCharger: String!
    static var requested: Bool?
    var myTimer: Timer!
    
    lazy var getHelpButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 110, g: 151, b: 261)
        button.setTitle("Help", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleGetHelp), for: .touchUpInside)//TODO-- change selector back to handleGetHelp
        
        return button
    }()
    

    
    let textMessage: UITextField = {
        let text = UITextField()
        
        //let rect = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        //text.borderRect(forBounds: rect)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.placeholder = "Help! I'm in GSR G60!"
        let myColor : UIColor = UIColor.gray
        text.layer.borderColor = myColor.cgColor
        text.layer.borderWidth = 1.0
        return text
    }()
    
    let chargerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "What do you need?"
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Where are you?"
        return label
    }()
    
    let messageView: UITextView = {
        let text = UITextView()
        
        text.translatesAutoresizingMaskIntoConstraints = false
        
        text.layer.borderWidth = 1.0;
        text.layer.borderColor = UIColor.black.cgColor
        //text.font = UIFont.init(name: "Roboto-Regular", size: 45)
        
        return text
    }()
    
    let chargerPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NetworkManager.getOutstandingRequest()
        
        checkIfUserIsLoggedIn()
        
        MessagesController.requested = false;
        AppManager.requesting = false;
        AppManager.handlingRequest = false;
        needCharger = Products.options[0]
        
        myTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(handleGet), userInfo: nil, repeats: true)
        
        handleCheckRequests()
        
        setupController()
    }
    
    func setupController() {
        
        view.backgroundColor = UIColor.white
        needCharger = Products.options[0]
        
        view.addSubview(getHelpButton)
        view.addSubview(textMessage)
        //view.addSubview(messageView)
        view.addSubview(chargerPicker)
        view.addSubview(locationLabel)
        view.addSubview(chargerLabel)
        
        setupGetHelpButton()
        setupTextMessage()
        //setupMessageView()
        setupPickerView()
        setupLocationLabel()
        setupChargerLabel()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "Create New-50")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleProfile))
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func checkIfUserIsLoggedIn() {
        // user is not loggen in
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
//            let uid = FIRAuth.auth()?.currentUser?.uid
//            let ref = FIRDatabase.database().reference().child("users").child(uid!)
//            ref.observeSingleEvent(of: .value, with: { (snapshot) in
//                
//                print(snapshot)
////                                if let dictionary = snapshot.value as? [String: AnyObject] {
////                                    self.navigationItem.title = dictionary["name"] as? String
////                                    User.name = dictionary["name"] as? String
////                                    User.email = dictionary["email"] as? String
////                                    User.number = dictionary["number"] as? String
////                                }
//                ref.child(byAppendingPath: "name").observeSingleEvent(of: .value, with: { snapshot in
//                    
//                    print(snapshot.value ?? "myName")
//                    //self.navigationItem.title = snapshot.value ?? "testName" as? String
//                    
//                })
//                                //self.navigationItem.title = ref.child("name") as? String
//                
//            }, withCancel: nil)
            FIRAuth.auth()!.addStateDidChangeListener { auth, user in
                guard let user = user else { return }
                ThisUser.user = User(authData: user)
                //print(ThisUser.user!.email)
                let uid = ThisUser.user!.uid
                let ref = FIRDatabase.database().reference().child("users").child(uid)
                //let ref = FIRDatabase.database().reference().child("users").child(uid).child("name")
//                ref.observeSingleEvent(of: .value, with: { (snapshot) in
//                    //print(snapshot.value ?? "testName")
//                    if let name = snapshot.value {
//                        ThisUser.name = name as? String
//                    }
//                    print(ThisUser.name!)
//                })
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        self.navigationItem.title = dictionary["name"] as? String
                        ThisUser.name = dictionary["name"] as? String
                        ThisUser.email = dictionary["email"] as? String
                        ThisUser.number = dictionary["number"] as? String
                        ThisUser.uid = uid
                        //print(dictionary["name"])
                        print("success")
                    }
                })
            }
        }
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
        textMessage.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
        textMessage.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupMessageView() {
        messageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        messageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -250).isActive = true
        messageView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        messageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupLocationLabel() {
        locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        locationLabel.bottomAnchor.constraint(equalTo: textMessage.topAnchor, constant: -12).isActive = true
    }
    
    func setupChargerLabel() {
        chargerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        chargerLabel.bottomAnchor.constraint(equalTo: chargerPicker.topAnchor, constant: -12).isActive = true
    }
    
    func setupPickerView() {
        chargerPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        chargerPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        chargerPicker.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        chargerPicker.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        chargerPicker.delegate = self
        chargerPicker.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Products.options.count
    }
    
    //MARK: -  UIPickerView delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Products.options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        needCharger = Products.options[row]
    }
    
//    func fetchUserAndSetupNavBarTitle() {
//        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
//            return
//        }
//        
//        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                let user = User()
//                user.setValuesForKeys(dictionary)
//                self.setupNavBarWithUser(user: user)
//            }
//            
//        }, withCancel: nil)
//    }
//    
//    func setupNavBarWithUser(user: User) {
//        self.navigationItem.title = user.name
//    }
}

