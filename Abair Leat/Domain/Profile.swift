//
//  Profile.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 27/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import Foundation
import Firebase
import Haneke

class Profile {
    
    let id: String
    let name: String
    let firstName: String
    let lastName: String
    let avatarUrlString: String
    var avatar: UIImage?
    
    init(id: String, name: String, firstName: String, lastName: String, avatarUrl: String) {
        self.id = id
        self.name = name
        self.firstName = firstName
        self.lastName = lastName
        self.avatarUrlString = avatarUrl
        
        // attempt to pre-load the avatar here
        let cache = Shared.imageCache
        let URL = NSURL(string: self.avatarUrlString)!
        cache.fetch(URL: URL).onSuccess { (image) -> () in
            self.avatar = image
        }
    }
    
    convenience init(facebookProfile: NSDictionary) {
        let picture = facebookProfile["picture"] as! NSDictionary
        let data = picture["data"] as! NSDictionary
        self.init(id: facebookProfile["id"] as! String, name: facebookProfile["name"] as! String, firstName:  facebookProfile["first_name"] as! String, lastName: facebookProfile["last_name"] as! String, avatarUrl: data["url"] as! String)
    }
    
    convenience init(firebaseSnapshot: NSDictionary) {
        let val = firebaseSnapshot
        self.init(id: val["id"] as! String, name: val["name"] as! String, firstName:  val["firstName"] as! String, lastName: val["lastName"] as! String, avatarUrl: val["avatarUrlString"] as! String)
    }
    
    func initials() -> String {
        return "\(firstName.characters.first!)\(lastName.characters.first!)"
    }
    
    func toDict() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict.setObject(id, forKey: "id")
        dict.setObject(name, forKey: "name")
        dict.setObject(firstName, forKey: "firstName")
        dict.setObject(lastName, forKey: "lastName")
        dict.setObject(avatarUrlString, forKey: "avatarUrlString")
        return dict
    }
    
}