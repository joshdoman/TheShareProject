//
//  ProfileViewController.swift
//  TheShareProject
//
//  Created by Josh Doman on 11/17/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var option: String!
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var options: UIPickerView!
    @IBOutlet weak var shareNum: UILabel!
    @IBOutlet weak var borrowNum: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupController()
        // Do any additional setup after loading the view.
    }

    func setupController() {
        
        setupProfileImage()
        setupPickerView()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
    }
    
    func handleBack() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupProfileImage() {
        profile.image = UIImage(named: "Pic")
        //profile.contentMode = .scaleAspectFill
    }
    
    func setupPickerView() {
        options.delegate = self
        options.dataSource = self
        
        option = Products.options[0]
    }
    
    
    @IBAction func save(_ sender: UIButton) {
        print(option)
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
        option = Products.options[row]
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
