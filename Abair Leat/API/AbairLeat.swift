//
//  API.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 27/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import Foundation
import Firebase

class AbairLeat {

    static let shared = AbairLeat()
    static let DATA_VERSION = "v1"
    static let FIREBASE_URL = "https://abair-leat.firebaseio.com/"
    
    let baseFirebaseRef :Firebase
    let versionedFirebaseRef :Firebase
    let profile = ProfileService()
    let contacts = ContactsService()
    let conversations = ConversationsService()
    
    private init() {
        Firebase.defaultConfig().persistenceEnabled = true
        baseFirebaseRef = Firebase(url: AbairLeat.FIREBASE_URL)
        versionedFirebaseRef = Firebase(url: AbairLeat.FIREBASE_URL).childByAppendingPath(AbairLeat.DATA_VERSION)
    }
    
}