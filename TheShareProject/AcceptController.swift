//
//  AcceptController.swift
//  TheShareProject
//
//  Created by Josh Doman on 11/17/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

class AcceptController: UIViewController {

    
    @IBOutlet weak var request: UILabel!
    @IBOutlet weak var requestMsg: UILabel!
    @IBOutlet weak var requestProfile: UIImageView!
    
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
        dismiss(animated: true, completion: nil)
    }

    
    
    
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
