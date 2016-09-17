//
//  LoginSignupViewController.swift
//  NagSnapChat
//
//  Created by nag on 17.09.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse
import ParseUI


class LoginSignupViewController: PFLogInViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        
//        title = "NagSnapChat"
        
        let signUpVC = PFSignUpViewController()
        signUpVC.delegate = self
        self.delegate = self
        
        self.signUpController = signUpVC
    }
    
    func showInbox() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}


extension LoginSignupViewController: PFSignUpViewControllerDelegate {
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        dismissViewControllerAnimated(true, completion: nil)
        showInbox()
    }
}


extension LoginSignupViewController: PFLogInViewControllerDelegate {
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        showInbox()
    }
}












