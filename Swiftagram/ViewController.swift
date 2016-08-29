//
//  ViewController.swift
//  Swiftagram
//
//  Created by Ethan Thomas on 8/29/16.
//  Copyright © 2016 Ethan Thomas. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ViewController: PFLogInViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.fields = [.logInButton, .passwordForgotten, .signUpButton, .usernameAndPassword]
        self.delegate = self
        self.signUpController?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            performSegue(withIdentifier: "segueToFeed", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    func log(_ logInController: PFLogInViewController, didLogIn user: PFUser) {
        self.performSegue(withIdentifier: "segueToFeed", sender: nil)
    }
    
    func log(_ logInController: PFLogInViewController, didFailToLogInWithError error: Error?) {
        if let err = error {
            print(err.localizedDescription)
        }
    }
    
    func signUpViewController(_ signUpController: PFSignUpViewController, didSignUp user: PFUser) {
        dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "segueToFeed", sender: nil)
    }
}

