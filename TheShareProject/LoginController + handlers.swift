//
//  LoginController + handlers.swift
//  TheShareProject
//
//  Created by Josh Doman on 11/22/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        //        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {
        //            (user, error) in
        //
        //            if error != nil {
        //                //print("HEELLLOOO")
        //                print(error!)
        //                return
        //            }
        //
        //            //successfully logged in our user
        //            self.dismiss(animated: true, completion: nil)
        //
        //        })
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password)
    }
    
    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let number = numberTextField.text else {
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authenticated user
            let ref = FIRDatabase.database().reference(fromURL: "https://theshareproject-ba012.firebaseio.com/")
            
            let usersReference = ref.child("users").child(uid) //make users reference
            
            let values = ["name": name, "email": email, "number": number]
            
            //            User.name = name
            //            User.email = email
            //            User.number = number
            
            //            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref)
            //                in
            //
            //                if err != nil {
            //                    print(err!)
            //                    return
            //                }
            //
            //                self.dismiss(animated: true, completion: nil)
            //                
            //                //print("Saved user successfully")
            //            })
            
            usersReference.updateChildValues(values)
            
        })
    }
    
    func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0{
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        // change height of inputContainerView, but how??
        inputsContainerViewHeightAnchor?.constant =
            loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 200
        
        // change height of nameTextField
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/4)
        nameTextFieldHeightAnchor?.isActive = true
        nameTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? true : false
        
        // change height of emailTextField
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/4)
        emailTextFieldHeightAnchor?.isActive = true
        
        // change height of passwordTextField
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/4)
        passwordTextFieldHeightAnchor?.isActive = true
        
        // change height of nameTextField
        numberTextFieldHeightAnchor?.isActive = false
        numberTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/4)
        numberTextFieldHeightAnchor?.isActive = true
        numberTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? true : false
        
    }
}

