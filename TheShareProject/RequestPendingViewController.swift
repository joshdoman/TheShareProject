//
//  RequestPendingViewController.swift
//  TheShareProject
//
//  Created by Alessandro Portela on 11/18/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

class RequestPendingViewController: UIViewController {

    @IBOutlet weak var pendingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupController()
        
        setupLabels()
        // Do any additional setup after loading the view.
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
