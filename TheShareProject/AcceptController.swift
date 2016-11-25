//
//  AcceptController.swift
//  TheShareProject
//
//  Created by Josh Doman on 11/17/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

class AcceptController: UIViewController {

    
    @IBOutlet weak var requestItem: UILabel!
    @IBOutlet weak var requestMsg: UILabel!
    @IBOutlet weak var requestProfile: UIImageView!
    
    var messageController: MessagesController?
    var request: Request?
    var requestId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }
    
    func setupController() {
        setupImage()
    }
    
    func setupImage() {
        requestProfile.image = UIImage(named: "Pic")
    }

    
    @IBAction func accept(_ sender: UIButton) {
        print(requestMsg.text ?? "no message")
    }
    
    
    @IBAction func deny(_ sender: Any) {
        _ = messageController?.requestDictionary.removeValue(forKey: requestId!)
        messageController?.requests.remove(at: (messageController?.requests.index(of: requestId!))!)
        UserDefaults.standard.setIsHandlingRequest(value: false)
        dismiss(animated: true, completion: nil)
        //AppManager.handlingRequest = false    //makes pop back up
    }

}
