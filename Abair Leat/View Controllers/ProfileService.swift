//
//  ProfileService.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 27/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import Foundation
import Firebase
import FBSDKCoreKit

class ProfileService {
    
    var profilesRef: Firebase {
        get{
            return AbairLeat.shared.versionedFirebaseRef.childByAppendingPath("profiles")
        }
    }
    var myProfileRef: Firebase?
    
    var me: Profile? {
        didSet {
            if let profile = me {
                print("Welcome \(profile.name) (\(profile.id))")
                let profileRef = profilesRef.childByAppendingPath(profile.id)
                profileRef.updateChildValues(profile.toDict() as [NSObject: AnyObject])
                self.myProfileRef = profileRef
            }
        }
    }
    
    func profileRefForUser(id: String) -> Firebase {
        return profilesRef.childByAppendingPath(id)
    }
    
    func profileForUser(profileId :String, callback:(Profile?)-> Void) {
        AbairLeat.shared.profile.profileRefForUser(profileId).observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
            if snapshot.exists() {
                callback(Profile(firebaseSnapshot: snapshot.value as! NSDictionary))
            } else {
                callback(nil)
            }
        })
    }
    
    // Logs into firebase
    func login(facebookAccessToken: String, callback: (Profile?, NSError?) -> Void) {
        AbairLeat.shared.baseFirebaseRef.authWithOAuthProvider("facebook", token: facebookAccessToken,
            withCompletionBlock: { error, authData in
                if error != nil {
                    callback(nil, error)
                    return
                }
                self.userDidLogin({ (profile, error) -> Void in
                    callback(profile, error)
                })
        })
    }
    
    // refreshes the user's profile with data from Facebook
    func userDidLogin(callback: (Profile?, NSError?) -> Void) {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name,first_name,last_name,picture"]).startWithCompletionHandler { (connection, result, error) -> Void in
            if error != nil {
                print(error)
                callback(nil, error)
                return
            }
            self.me = Profile(facebookProfile: result as! NSDictionary)
            AbairLeat.shared.contacts.syncContactsWithFacebook()
            self.requestPushNotificationToken()
            callback(self.me, nil)
        }
    }
    
    func requestPushNotificationToken() {
        let types: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Sound, UIUserNotificationType.Badge]
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func logout() {
        AbairLeat.shared.baseFirebaseRef.unauth()
        self.myProfileRef = nil
        self.me = nil;
    }
    
}