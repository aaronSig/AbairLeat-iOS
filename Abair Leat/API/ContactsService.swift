//
//  ContactsService.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 27/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

//
// fetches all the user's contacts from facebook. Note facebook only shows us friends who also have the app installed and not all the user's friends.
//

import Firebase
import FBSDKCoreKit

class ContactsService {
    
    func myContactsRef() -> Firebase? {
        return AbairLeat.shared.profile.myProfileRef?.childByAppendingPath("contacts")
    }
    
    // pulls down facebook friends.
    func syncContactsWithFacebook() {
        let request = FBSDKGraphRequest(graphPath:"/me/friends", parameters: ["fields": "name,first_name,last_name,picture"]);
        request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            if error != nil {
                print("Error Getting Friends \(error)");
                return
            }
            
            let friendsData = result["data"] as! NSArray
            for friend: NSDictionary in friendsData as! [NSDictionary] {
                let profile = Profile(facebookProfile: friend)
                // set the priority value as the last name to auto order by name
                
                // Need to conifrm the user's profile is in our system
                AbairLeat.shared.profile.profileRefForUser(profile.id).observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
                    if snapshot.exists() {
                        self.addOrUpdateToContacts(profile.id)
                    } else {
                        // we should probably remove this in production. Creates a profile if the user's profile was deleted
                        AbairLeat.shared.profile.profileRefForUser(profile.id).setValue(profile.toDict(), withCompletionBlock: { (_, _) -> Void in
                            self.addOrUpdateToContacts(profile.id)
                        })
                    }
                })
            }
        }
    }
    
    func addOrUpdateToContacts(profileId :String) {
        if AbairLeat.shared.profile.me?.id != profileId {
            AbairLeat.shared.profile.profileForUser(profileId) { (profile) -> Void in
                if let profile = profile  {
                    self.myContactsRef()?.childByAppendingPath(FDataSnapshot.linkify(["profiles", profile.id])).setValue(profile.name, andPriority: profile.lastName)
                }
            }
        }
    }
    
}
