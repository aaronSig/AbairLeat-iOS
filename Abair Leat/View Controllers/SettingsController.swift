//
//  SettingsController.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 27/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class SettingsController: UITableViewController {

    @IBAction func logout() {
        
        
        
        self.performSegueWithIdentifier("unwindToLogin", sender: self)
    }

}
