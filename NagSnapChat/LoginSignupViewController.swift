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
        self.navigationController?.isNavigationBarHidden = true
        
//        title = "NagSnapChat"
        
        let signUpVC = PFSignUpViewController()
        signUpVC.delegate = self
        self.delegate = self
        
        self.signUpController = signUpVC
        
        // configure the logo
        logInView?.logo = UIImageView(image: UIImage(named: "Icon_120"))
        logInView?.logo?.contentMode = .scaleAspectFit
        
        signUpVC.signUpView?.logo = UIImageView(image: UIImage(named: "Icon_120"))
        signUpVC.signUpView?.logo?.contentMode = .scaleAspectFit
        
    }
    
    func showInbox() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func setupUserInstallation() {
        let installation = PFInstallation.current()
        installation!["user"] = PFUser.current()
        installation?.saveInBackground()
        
    }
    
    
    
}


extension LoginSignupViewController: PFSignUpViewControllerDelegate {
    func signUpViewController(_ signUpController: PFSignUpViewController, didSignUp user: PFUser) {
        
        setupUserInstallation()
        
        dismiss(animated: true, completion: nil)

        showInbox()
    }
}


extension LoginSignupViewController: PFLogInViewControllerDelegate {
    func log(_ logInController: PFLogInViewController, didLogIn user: PFUser) {
        
        
        setupUserInstallation()

        showInbox()
    }
}












