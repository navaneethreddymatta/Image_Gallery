//
//  HomeViewController.swift
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

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    var curUser = FIRAuth.auth()?.currentUser
    let imagePicker = UIImagePickerController()
    let ref = FIRDatabase.database().reference()
    var myImages = [MyImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //print("loading...")
        fetchData()
    }
    
    func fetchData() {
        ref.child("Users").child((curUser?.uid)!).child("Images").observeEventType(.Value, withBlock: { (snapshot) -> Void in
            self.myImages.removeAll()
            let enumerator = snapshot.children
            while let img = enumerator.nextObject() as? FIRDataSnapshot {
                let keyValue = img.key
                let url = img.value!["urlVal"] as? String
                let name = img.value!["name"] as? String
                let imgObj = MyImage(metaURL:url!,keyVal:keyValue, imgName:name!)
                self.myImages.append(imgObj)
            }
            self.collectionView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    @IBAction func logoutUser(sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : UIViewController = storyboard.instantiateViewControllerWithIdentifier("LoginStoryBoard") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func addPhotoToAlbum(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] {
            selectedImageFromPicker = editedImage as? UIImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedImageFromPicker = originalImage as? UIImage
        }
        dismissViewControllerAnimated(true, completion: nil)
        let imageName = NSUUID().UUIDString
        let storageRef = FIRStorage.storage().reference().child("\(imageName).png")
        if let uploadData = UIImagePNGRepresentation(selectedImageFromPicker!) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error)
                    return
                } else {
                    let newImageURLVal = metadata?.downloadURL()?.absoluteString
                    self.ref.child("Users").child((self.curUser?.uid)!).child("Images").childByAutoId().setValue(["name": imageName,"urlVal": newImageURLVal!])
                }
            })
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.myImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellIdentifier", forIndexPath: indexPath) as? ImageCollectionViewCell
        let imgObj = self.myImages[indexPath.row]
        cell!.imageView.contentMode = .ScaleAspectFill
        let imgURL = imgObj.metaURL
        if imgURL != "" {
            let url = NSURL(string: imgURL)
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error)
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    cell!.imageView?.image = UIImage(data: data!)
                })
            }).resume()
        }
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showImage", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //print("move to \(segue.identifier)")
        if segue.identifier == "showImage" {
            //print("moving now")
            let indexPaths = self.collectionView.indexPathsForSelectedItems()!
            let indexPath = indexPaths[0]
            let imageVC = segue.destinationViewController as? ImageViewController
            imageVC!.currentImage = self.myImages[indexPath.row]
        }
    }
}

struct MyImage {
    var metaURL: String
    var keyVal: String
    var imgName: String
}