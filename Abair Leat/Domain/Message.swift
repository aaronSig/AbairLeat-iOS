//
//  Message.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 27/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import Firebase

class Message: JSQMessage {
    
    var messageId: String? // unique ref for this message
    
    static func create(firebaseSnapshot: NSDictionary, author: Profile, messageId: String) -> Message {
        let message =  Message.init(senderId: author.id, senderDisplayName: author.name, date: NSDate.fromIsoDate(firebaseSnapshot["date"] as! String), text: firebaseSnapshot["text"] as! String)
        message.messageId = messageId
        return message
    }
    
    // true if the message was sent by the user
    func isOutgoing() -> Bool {
        return AbairLeat.shared.profile.me?.id == self.senderId
    }
    
}
