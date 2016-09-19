//
//  ImageViewController.swift
//  InClass10
//
//  Created by student on 8/4/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ImageViewController: UIViewController {
    var currentImage:MyImage?
    var curUser = FIRAuth.auth()?.currentUser
    let dbRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .ScaleAspectFill
        let imgURL = currentImage?.metaURL
        if imgURL != "" {
            let url = NSURL(string: imgURL!)
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error)
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.imageView?.image = UIImage(data: data!)
                })
            }).resume()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var imageView: UIImageView!

    
    @IBAction func deleteImage(sender: AnyObject) {
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Delete", message: "Are you sure you want to delete the image", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in
            self!.dbRef.child("Users").child((self!.curUser?.uid)!).child("Images").child((self!.currentImage?.keyVal)!).removeValue()
            let imageName = (self!.currentImage?.imgName)! + ".png"
            self!.storageRef.child(imageName).deleteWithCompletion({ (error) in
                if error != nil {
                    let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alert.addAction(action)
                    self!.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc : UIViewController = storyboard.instantiateViewControllerWithIdentifier("HomeStoryBoard") as UIViewController
                    self!.presentViewController(vc, animated: true, completion: nil)
                }
            })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in })
        
        alertController?.addAction(okAction)
        alertController?.addAction(cancelAction)
        presentViewController(alertController!, animated: true, completion: nil)
    }

}
