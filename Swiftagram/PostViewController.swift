//
//  PostViewController.swift
//  Swiftagram
//
//  Created by Ethan Thomas on 8/29/16.
//  Copyright © 2016 Ethan Thomas. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController {
    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var messageTextField: UITextField!
    
    var activityIndicatior = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @IBAction func chooseAnImage(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postAnImage(_ sender: AnyObject) {
        if imageToPost.image == UIImage(named: "person") {
            self.showAlert(title: "Error", message: "Please select an image other than the default image!")
        } else {
            activityIndicatior = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicatior.center = self.view.center
            activityIndicatior.hidesWhenStopped = true
            activityIndicatior.activityIndicatorViewStyle = .gray
            view.addSubview(activityIndicatior)
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            let post = PFObject(className: "Posts")
            
            post["message"] = messageTextField.text
            
            post["userID"] = PFUser.current()?.objectId!
            
            let imageData = UIImagePNGRepresentation(imageToPost.image!)!
            
            let imageFile = PFFile(name: "image.png", data: imageData)
            
            post["imageFile"] = imageFile
            
            post.saveInBackground { (success, error) in
                self.activityIndicatior.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                if let err = error {
                    self.showAlert(title: "Could not post image", message: err.localizedDescription)
                } else {
                    self.showAlert(title: "Image Posted!", message: "Your image has been posted successfully")
                    self.messageTextField.text = ""
                    self.imageToPost.image = UIImage(named: "person")
                }
            }
        }
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

extension PostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageToPost.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
}
