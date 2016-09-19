//
//  LoginViewController.swift
//  InClass10
//
//  Created by student on 8/4/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        let curUser = FIRAuth.auth()?.currentUser
        if curUser != nil {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : UIViewController = storyboard.instantiateViewControllerWithIdentifier("HomeStoryBoard") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginUser(sender: UIButton) {
        let email = emailField.text
        let password = passwordField.text
        if email == nil || email == "" || password == nil || password == "" {
            let alert = UIAlertController(title: "Alert", message: "Enter Your Credentials", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            FIRAuth.auth()?.signInWithEmail(email!, password: password!, completion: { (newUser, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc : UIViewController = storyboard.instantiateViewControllerWithIdentifier("HomeStoryBoard") as UIViewController
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            })
        }
    }
}
