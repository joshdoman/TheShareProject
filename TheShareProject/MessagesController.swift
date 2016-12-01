
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
    
    let blackView = UIView()
    
    func showMessageButton() {
        view.addSubview(blackView)
        
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        blackView.frame = view.frame
        blackView.alpha = 0
        
        //animation
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//            self.blackView.alpha = 1
//        }, completion: nil)
    }
    
    lazy var goToMessage: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to message", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleShowMessage), for: .touchUpInside)//TODO-- change selector back to handleGetHelp
        
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
        
        //NetworkManager.getOutstandingRequest()
        
        checkIfUserIsLoggedIn()
        
        needCharger = Products.options[0]
        
        setupController()
        
        //NetworkManager.checkFirebaseForOutstandingRequests(user: AppManager.currentUser!)
    }
    
    var requests = [String]()
    var requestDictionary = [String: Request]()
    
    private func fetchRequestsFromFirebase() {
        FIRDatabase.database().reference().child("requests").observe(.childAdded, with: { (snapshot) in

                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    let request = Request(dictionary: dictionary)
                    request.fromId = snapshot.key
                    self.requestDictionary[snapshot.key] = request
                }
                
                self.attemptReload()

        }, withCancel: nil)
        
        removeDeniedRequest()
        
        attemptReload()
    }
    
    func removeDeniedRequest() {
        guard let uid = AppManager.getCurrentUID() else {
            return
        }
        FIRDatabase.database().reference().child("denials").child(uid).observe(.childAdded, with: { (snapshot) in
            
            //print("removing \(snapshot.key)")
            self.requestDictionary.removeValue(forKey: snapshot.key)
            
        }, withCancel: nil)
    }
    
    var timer: Timer?
    var getTimer: Timer?
    
    private func attemptReload() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
    }
    
    func handleReload() {
        self.requests = Array<String>(self.requestDictionary.keys)
        print("requests \(self.requests)")
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
        view.addSubview(goToMessage)
        
        setupGetHelpButton()
        setupTextMessage()
        //setupMessageView()
        setupPickerView()
        setupLocationLabel()
        setupChargerLabel()
        setupGoToMessage()
        
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
        if AppManager.getCurrentUID() == nil {
            
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
        } else {
            
            fetchUserAndSetupNavBarTitle()

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
    
    func setupGoToMessage() {
        goToMessage.bottomAnchor.constraint(equalTo: chargerLabel.bottomAnchor, constant: -20).isActive = true
        goToMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        goToMessage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        goToMessage.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
    
    func fetchUserAndSetupNavBarTitle() {
        
        guard let uid = AppManager.getCurrentUID() else {
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.setValuesForKeys(dictionary)
                user.uid = uid
                self.setupNavBarWithUser(user: user)
            }
            
        }, withCancel: nil)
    }
    
    func showChatControllerForUser(user: User) {
        UserDefaults.standard.setIsHandlingRequest(value: true)
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func resetTimer() {
        myTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(handleGet), userInfo: nil, repeats: true)
    }
    
    func loadRequests() {
        fetchRequestsFromFirebase()
        removeDeniedRequest()
    }
    
    func resetMessageController() {
        UserDefaults.standard.setIsRequesting(value: false)
        UserDefaults.standard.setIsHandlingRequest(value: false)
        
        requests.removeAll()
        requestDictionary.removeAll()
        
        loadRequests()
        
        print(requests)
        
        checkIfUserIsRequesting()
        
        //if(!UserDefaults.standard.isRequesting()) {
        checkIfUserIsHandlingRequest()
        //}
        
        
    }
    
    private func attemptTimerReset() {
        self.getTimer?.invalidate()
        self.getTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.handleReset), userInfo: nil, repeats: false)
    }
    
    func handleReset() {
        print("handling \(UserDefaults.standard.isHandlingRequest())")

        if !UserDefaults.standard.isHandlingRequest() {
            resetTimer()
        }
    }
    
    func setupNavBarWithUser(user: User) {
        
        //do other stuff to set up messagesController
        AppManager.currentUser = user

        resetMessageController()
        
        attemptTimerReset()
        
        //print(AppManager.currentUser?.name!)
        
        self.navigationItem.title = user.name
    }
}

