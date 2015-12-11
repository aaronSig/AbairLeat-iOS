//
//  LinkUtils.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 08/12/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import UIKit
import Firebase

extension FDataSnapshot {

    func isALink() -> Bool {
        return self.key.hasPrefix("@link>")
    }
    
    func linkPathComponents() -> [String] {
        let link = self.key
        return link.stringByReplacingOccurrencesOfString("@link>", withString: "").componentsSeparatedByString(">")
    }
    
    func linkToRef() -> Firebase {
        let link = self.key
        let path = link.stringByReplacingOccurrencesOfString("@link>", withString: "").componentsSeparatedByString(">").joinWithSeparator("/")
        return AbairLeat.shared.versionedFirebaseRef.childByAppendingPath(path)
    }
    
    // constructs one of our custom links. Should always be used as keys
    static func linkify(components: [String]) -> String {
        return "@link>" + components.joinWithSeparator(">")
    }
    
}
