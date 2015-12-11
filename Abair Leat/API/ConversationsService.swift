//
//  ConversationsService.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 27/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import Foundation
import Firebase

class ConversationsService {
    
    var baseConversationRef: Firebase {
        get {
            return AbairLeat.shared.versionedFirebaseRef.childByAppendingPath("/conversations")
        }
    }
    
    var referenceDate: NSDate {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            return dateFormatter.dateFromString("31-Dec-2200")!
        }
    }
    
    func firebaseRefForConversation(id: String) -> Firebase {
        return baseConversationRef.childByAppendingPath(id)
    }
    
    // Returns the created conversation id
    func createConversation(name: String, participantIds: [String], creatorId: String) -> String {
        let conversationRef = baseConversationRef.childByAutoId()
        if participantIds.count == 1 {
            return createOneToOneConversation(participantIds[0])
        }
        conversationRef.childByAppendingPath("metadata").updateChildValues([
            "name" : name,
            "creator": creatorId,
            "participants": participantIds,
            "conversationId": conversationRef.key
            ])
        updateRecentConversations(conversationRef.key)
        return conversationRef.key
    }
    
    func createOneToOneConversation(otherParticipant: String)  -> String  {
        let conversationRef = baseConversationRef.childByAppendingPath(getOneToOneConversationId(otherParticipant))
        conversationRef.childByAppendingPath("metadata").updateChildValues([
            "participants": [AbairLeat.shared.profile.me!.id, otherParticipant],
            "oneOnOne": true,
            "conversationId": conversationRef.key
            ])
        return conversationRef.key
    }
 
    func sendMessage(conversationId:String, message: String, complete: (Message) -> Void) {
        let author = AbairLeat.shared.profile.me!
        let messageDict = [
            "author": author.id,
            "text": message,
            "date": NSDate().toIsoFormat()
        ]
        
        let ref = self.firebaseRefForConversation(conversationId)
        ref.childByAppendingPath("metadata").updateChildValues([
            "dateLastMessageSent": NSDate().toIsoFormat(),
            "lastMessageSent": message,
            "lastSenderName": author.name,
            "lastSenderAvatarUrl": author.avatarUrlString
            ])
        
        updateRecentConversations(conversationId)
        let messageRef = ref.childByAppendingPath("messages").childByAutoId()
        messageRef.setValue(messageDict, withCompletionBlock: { (error, firebaseRef) -> Void in
            let me = AbairLeat.shared.profile.me!
            let sentMessage = Message.init(senderId: me.id, senderDisplayName: me.name, date: NSDate(), text: message)
            sentMessage.messageId = messageRef.key
            complete(sentMessage)
        })
    }
    
    func didReceiveMessage(conversationId:String) {
        updateRecentConversations(conversationId)
    }
    
    func updateRecentConversations(conversationId :String) {
        // When a message is added to a conversation we need to bring that conversation to the top of the recents list
        // we store a link to the conversations a user is in in their profile
        // note priority is always ordered ascending so we use a reference date in the future
        
        let conversationMetadataLink = FDataSnapshot.linkify(["conversations", conversationId, "metadata"])
        let priority = self.referenceDate.timeIntervalSinceDate(NSDate())
        AbairLeat.shared.conversations.firebaseRefForConversation(conversationId).childByAppendingPath("metadata").observeSingleEventOfType(.Value, withBlock: { (metadataSnap) -> Void in
            let metadata = metadataSnap.value as! NSDictionary
            let participantIds = metadata["participants"] as! [String]
            for id in participantIds {
                AbairLeat.shared.profile.profileRefForUser(id).childByAppendingPath("conversations-metadata/\(conversationMetadataLink)").setValue(true, andPriority: priority)
            }
        })
    }
    
    // creates the ID for a conversation between the logged in user and the user passed in
    func getOneToOneConversationId(otherParticipantId: String) -> String {
        // 1-1 conversations always have the ID 1x[id]-[id] where ids are ordered alphabetically
        var ids = [otherParticipantId, AbairLeat.shared.profile.me!.id]
        ids.sortInPlace()
        return "1x\(ids[0])-\(ids[1])"
    }

}