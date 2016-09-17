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
        
        // !!!IMPORTANT
        self.navigationController?.navigationBarHidden = true
        
//        title = "NagSnapChat"
        
        let signUpVC = PFSignUpViewController()
        signUpVC.delegate = self
        self.delegate = self
        
        self.signUpController = signUpVC
        
        // configure the logo
        logInView?.logo = UIImageView(image: UIImage(named: "Icon_120"))
        logInView?.logo?.contentMode = .ScaleAspectFit
        
        signUpVC.signUpView?.logo = UIImageView(image: UIImage(named: "Icon_120"))
        signUpVC.signUpView?.logo?.contentMode = .ScaleAspectFit
        
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












