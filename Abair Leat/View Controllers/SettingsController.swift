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
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var provider: UILabel!
    
    override func viewDidLoad() {
        setupConnectedWatcher()
        setupProfile()
    }
    
    func setupConnectedWatcher() {
        let connectedRef = AbairLeat.shared.baseFirebaseRef.childByAppendingPath("/.info/connected")
        connectedRef.observeEventType(.Value, withBlock: { snapshot in
            let connected = snapshot.value as? Bool
            if connected != nil && connected! {
                self.status.text = "Connected"
                self.status.textColor = UIColor.greenColor()
            } else {
                self.status.text = "Offline"
                self.status.textColor = UIColor.redColor()
            }
        })
    }
    
    func setupProfile() {
        let fb = AbairLeat.shared.baseFirebaseRef
        self.provider.text = fb.authData?.provider
        
        let me = AbairLeat.shared.profile.me
        self.name.text = me?.name
        self.id.text = me?.id
    }
    
    @IBAction func logout() {
        self.performSegueWithIdentifier("unwindToLogin", sender: self)
    }
    
}
