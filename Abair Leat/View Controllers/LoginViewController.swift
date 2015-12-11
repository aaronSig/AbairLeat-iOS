//
//  LoginViewController.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 19/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SVProgressHUD
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    let manager = FBSDKLoginManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.hidden = true
        
        // check if we're already logged into facebook
        if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
            let fb = AbairLeat.shared.baseFirebaseRef
            let authData = fb.authData
            if authData != nil && (authData.auth["uid"] as! String == "facebook:\(fbAccessToken.userID)") {
                // already logged in
                AbairLeat.shared.profile.userDidLogin({ (_, _) -> Void in
                    self.loginComplete()
                })
            } else {
                login(FBSDKAccessToken.currentAccessToken().tokenString)
            }
        } else {
            // user isn't logged in
            loginButton.hidden = false
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        loginButton.hidden = true
        let permissions = ["public_profile", "user_friends"]
        manager.logInWithReadPermissions(permissions, fromViewController: self) {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                SVProgressHUD.showErrorWithStatus("Facebook login failed. Error \(facebookError)")
                self.loginButton.hidden = false
            } else if facebookResult.isCancelled {
                // don't need to do anything here. The user knows they cancelled
                self.loginButton.hidden = false
            } else {
                // hide the button whilst we login to Firebase
                self.loginButton.hidden = true
                self.login(FBSDKAccessToken.currentAccessToken().tokenString)
            }
        }
    }

    func login(facebookAccessToken: String) {
        AbairLeat.shared.profile.login(facebookAccessToken) { (profile, error) -> Void in
            if error != nil {
                SVProgressHUD.showErrorWithStatus("Login failed. \(error)")
                self.loginButton.hidden = false
                return
            }
            self.loginComplete()
        }
    }
    
    func loginComplete() {
        self.performSegueWithIdentifier("start_app", sender: self)
        
        // Ask the user for permission to send push notifications
        AbairLeat.shared.profile.requestPushNotificationToken()
    }
    
    @IBAction func unwindToLogin(sender: UIStoryboardSegue)
    {
        FBSDKLoginManager().logOut()
        loginButton.hidden = false
    }
    
}
