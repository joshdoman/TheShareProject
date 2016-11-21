
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
    var requested: Bool?
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
    
    func handleGetHelp() {
        if let text = textMessage.text {
            if text == "" {
              print("Where are you?")
            } else {
              print("I need a " + needCharger + ". " + text)
                let item = needCharger!
                let location = text
                let username = ThisUser.name!
                let uid = ThisUser.uid!
                let number = ThisUser.number!
                
                // Send POST request to /notify/all
                
                sendRequest(item: item, location: location, username: username, uid: uid, number: number)
                
                handleSegue(type: "request")
                
                AppManager.requesting = true;
            }
        }
    }
    
    func handleCheckRequests() {
        //Send GET request to /info
        
        //TODO
        getRequest()
    }
    
    func sendRequest(item: String, location: String, username: String, uid: String, number: String) {
//        var request = URLRequest(url: URL(string: "http://localhost:3000/notify/all")!)
//        request.httpMethod = "POST"
//        let postString = "item=\(item)&username=\(username)&location=\(location)"
//        request.httpBody = postString.data(using: .utf8)
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {                                                 // check for fundamental networking error
//                print("error=\(error)")
//                return
//            }
//            
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(response)")
//            }
//            
//            let responseString = String(data: data, encoding: .utf8)
//            print("responseString = \(responseString)")
//        }
//        task.resume()
        
        let url = URL(string: "http://localhost:3000/notify/all")
        
//        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        
        var request = NSMutableURLRequest(url: url!)
        
        request.httpMethod = "POST"
        do {
            let params = ["item":item, "location":location,"username":username,"uid":uid,"number":number]
            
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
    
    //This function sends a get request to the server, getting back a list of all users who are currently requesting a charger and a boolean indicating if there are any users requesting or not.
    func getRequest() {
        let url = URL(string: "http://localhost:3000/info")
        
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
//                let json = try! JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
////                print("Here is the server response data!\n")
//                    print(json)
                let resultNSString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                if resultNSString != "" {
                        print(resultNSString)
                        self.requested = true;
                } else {
                    //do nothing
                    //TODO-- potential security vulnerability with checking for ""-- ask Yagil
                }
            })
            task.resume()
        }
    }
    
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
        
        checkIfUserIsLoggedIn()
        
        requested = false;
        AppManager.requesting = false;
        AppManager.handlingRequest = false;
        needCharger = Products.options[0]
        
        myTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(handleGet), userInfo: nil, repeats: true)
        
        handleCheckRequests()
        
        setupController()
    }
    
    func handleGet()
    {
        if AppManager.handlingRequest! == false && AppManager.requesting! == false {
            handleCheckRequests()
            if requested! == true {
                AppManager.handlingRequest = true
                requested = false
                handleSegue(type: "accept") //go to new viewcontroller
            }
        }
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
    
    func handleProfile() {
        handleSegue(type: "profile")
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func handleSegue(type: String) {
        if type == "profile" {
            
        let profileController = ProfileViewController()
        let navController = UINavigationController(rootViewController: profileController)
        present(navController, animated: true, completion: nil)
            
        } else if type == "accept" {
            
            let acceptController = AcceptController()
            let navController = UINavigationController(rootViewController: acceptController)
            present(navController, animated: true, completion: nil)
            
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
        present(loginController, animated: true, completion: nil)
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
}

