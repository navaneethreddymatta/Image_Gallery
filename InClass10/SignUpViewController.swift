//
//  SignUpViewController.swift
//  InClass10
//
//  Created by student on 8/4/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBAction func cancelUserCreation(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func submitUser(sender: UIButton) {
        let dName = name.text
        let emailID = email.text
        let uPassword = password.text
        let uConfirmPassword = confirmPassword.text
        
        if dName == nil || dName == "" || emailID == nil || emailID == "" || uPassword == nil || uPassword == "" || uConfirmPassword == nil || uConfirmPassword == "" {
            let alert = UIAlertController(title: "Alert", message: "Enter Your Details", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        } else if uPassword != uConfirmPassword {
            let alert = UIAlertController(title: "Alert", message: "Passwords do not match", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            FIRAuth.auth()?.createUserWithEmail(emailID!, password: uPassword!, completion: { (newUser, error) in
                if error != nil {
                    
                    let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let ref = FIRDatabase.database().reference()
                    ref.child("Users").child((newUser?.uid)!).setValue(["name": dName!,"email": emailID!,"password": uPassword!])
                    // --------- login from here --------------
                    FIRAuth.auth()?.signInWithEmail(emailID!, password: uPassword!, completion: { (newUser, error) in
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
            })
        }
    }
}

