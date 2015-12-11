//
//  Conversation.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 30/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import UIKit
import Firebase

class ConversationMetadata: NSObject {

    let conversationId: String
    let name: String?
    let isOneToOne: Bool // if the message is just between two people
    let participants: [String: Profile]
    let dateLastMessageSent: NSDate?
    let lastMessageSent: String?
    let lastSenderName: String?
    let lastSenderAvatarUrl: String?
    
    init(conversationId: String, name: String?, isOneToOne: Bool, dateLastMessageSent: NSDate?, lastMessageSent:String?, lastSenderName:String?, lastSenderAvatarUrl:String?, participants:[String: Profile]) {
        self.conversationId = conversationId
        self.name = name
        self.isOneToOne = isOneToOne
        self.dateLastMessageSent = dateLastMessageSent
        self.lastMessageSent = lastMessageSent
        self.lastSenderName = lastSenderName
        self.lastSenderAvatarUrl = lastSenderAvatarUrl
        self.participants = participants
    }
    
    convenience init(firebaseSnapshot: NSDictionary, participants:[String: Profile]) {
        let val = firebaseSnapshot
        let conversationId = val["conversationId"] as! String
        let name = val["name"] as? String
        let oneOnOne = val["oneOnOne"] as! Bool
        var date: NSDate? = nil
        if let dateStr = val["dateLastMessageSent"] as? String {
            date = NSDate.fromIsoDate(dateStr)
        }
        let lastMessageSent = val["lastMessageSent"] as? String
        let lastSenderName = val["lastSenderName"] as? String
        let lastSenderAvatarUrl = val["lastSenderAvatarUrl"] as? String
            
        self.init(conversationId: conversationId, name: name, isOneToOne: oneOnOne, dateLastMessageSent: date, lastMessageSent: lastMessageSent, lastSenderName:lastSenderName, lastSenderAvatarUrl:lastSenderAvatarUrl, participants: participants)
    }
    
    func getConversationName() -> String? {
        // if we have a name use that
        // if this is one on one then use the other persons name
        // if neither then return nil
        
        if let name = name  {
            return name
        }
        
        if isOneToOne {
            return getParticipantsWithoutMe()[0].name
        }
        
        return nil
    }
    
    func getParticipantsWithoutMe() -> [Profile] {
        // returns the participants without the logged in user
        var p = [Profile]()
        for (id, profile) in participants {
            if id != AbairLeat.shared.profile.me?.id {
                p.append(profile)
            }
        }
        return p
    }
    
}
