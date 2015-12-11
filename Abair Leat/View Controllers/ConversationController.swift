//
//  ConversationController.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 27/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import SVProgressHUD

//
// The actaul messaging window
//
class ConversationController: JSQMessagesViewController {
    
    let outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(hex: "#FFC107"))
    let incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(hex: "#0097A7"))
    var messages = [Message]()
    var firebase: Firebase?

    var metadata: ConversationMetadata? {
        didSet {
            if let conversationName = metadata?.getConversationName() {
                self.title = conversationName
            }
        }
    }
    
    var conversationId: String? {
        didSet {
            if let conversation = conversationId {
                self.firebase = AbairLeat.shared.conversations.firebaseRefForConversation(conversation)
                self.firebase!.keepSynced(true)
                
                //only show the progress if its taking longer than a second to load
                NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "showProgress", userInfo: nil, repeats: false)
                self.initialLoadAndAttach(self.firebase!)
            }
        }
    }
    
    // we only want to show progress if the load is taking a while
    var isShowingProgressHUD = false
    var isLoaded = false
    func showProgress() {
        if isLoaded == false {
            isShowingProgressHUD = true
            SVProgressHUD.showProgress(0.45, status: "Fetching messages")
        }
    }
    
    // MARK: - Firebase

    func initialLoadAndAttach(ref: Firebase) {
        // preload all metadata and participant profiles then do first batch of messages
        ref.childByAppendingPath("metadata").observeSingleEventOfType(.Value, withBlock: { snapshot in
            let metadata = snapshot.value as! NSDictionary
            let participantIds = metadata["participants"] as? [String]
            var participants = [String: Profile]()
            if let participantIds = participantIds {
                for id in participantIds {
                    AbairLeat.shared.profile.profileRefForUser(id).observeSingleEventOfType(.Value, withBlock: { (profileSnapshot) -> Void in
                        let participant = Profile(firebaseSnapshot: profileSnapshot.value as! NSDictionary)
                        participants[participant.id] = participant
                        if participants.count == participantIds.count {
                            self.metadata = ConversationMetadata(firebaseSnapshot: metadata, participants: participants)
                            self.initialBatchLoadOfMessages(ref)
                        }
                    })
                }
            }
        })
    }
    
    func initialBatchLoadOfMessages(ref: Firebase) {
        if isShowingProgressHUD {
            SVProgressHUD.showProgress(0.45, status: "Fetching messages")
        }
        // note we only load 200 messages
        ref.childByAppendingPath("messages").queryLimitedToLast(200).observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let child: AnyObject = enumerator.nextObject() {
                let messageSnapshot = child as! FDataSnapshot
                let message = messageSnapshot.value as! NSDictionary
                let author: Profile = self.metadata!.participants[message["author"] as! String]!
                self.messages.append(Message.create(message, author: author, messageId: messageSnapshot.key))
            }
    
            self.collectionView?.reloadData()
            self.finishReceivingMessageAnimated(false)
            self.attachObservers(ref)
        })
    }
    
    func attachObservers(ref: Firebase) {
        if isShowingProgressHUD {
            SVProgressHUD.showSuccessWithStatus("Done")
        }
        isLoaded = true
        // listen for new messages
        ref.childByAppendingPath("messages").queryLimitedToLast(200).observeEventType(.ChildAdded, withBlock: { snapshot in
            let message = snapshot.value as! NSDictionary
            let authorId = message["author"] as! String
            if authorId == AbairLeat.shared.profile.me?.id {
                // this message was sent by the logged in user. We can ignore as we add these in the didPressSendButton(..) func below
                return
            }
            if self.messages.contains({$0.messageId == snapshot.key}) {
                // we alredy have this message
                return
            }
            
            let author: Profile = self.metadata!.participants[authorId]!
            self.messages.append(Message.create(message, author: author, messageId: snapshot.key))
            self.finishReceivingMessageAnimated(true)
        })
        
        // remove deleted messages
        ref.childByAppendingPath("messages").observeEventType(.ChildRemoved, withBlock: { snapshot in
            // remove message with matching ID
            self.messages = self.messages.filter({ (message) -> Bool in
                return message.messageId != snapshot.key
            })
            self.collectionView?.reloadData()
        })
    }
    
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyScrollsToMostRecentMessage = true
        super.senderDisplayName = AbairLeat.shared.profile.me!.name
        super.senderId = AbairLeat.shared.profile.me?.id

        self.showLoadEarlierMessagesHeader = false
        self.inputToolbar?.contentView?.leftBarButtonItem = nil
        
        JSQMessagesCollectionViewCell.registerMenuAction("delete:")
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        self.inputToolbar?.contentView?.rightBarButtonItem?.enabled = false
        AbairLeat.shared.conversations.sendMessage(self.conversationId!, message: text) { (sentMessage) -> Void in
            self.messages.append(sentMessage)
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            self.finishSendingMessageAnimated(true)
        }
    }
    
    // MARK: - JSQMessagesCollectionViewDataSource
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages[indexPath.item]
        let author = self.metadata!.participants[message.senderId]!
        var avatar: JSQMessagesAvatarImage
        
        if let avatarImage = author.avatar {
            avatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(avatarImage, diameter: 50)
        } else {
            avatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(author.initials(), backgroundColor: UIColor.orangeColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(12), diameter: 50)
        }
        
        return avatar
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.item]
        if message.isOutgoing() {
            return self.outgoingBubbleImageView
        } else {
            return self.incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        if action == "delete:" {
            let message = self.messages[indexPath.item]
            return message.senderId == AbairLeat.shared.profile.me?.id
        }
        return true
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        let message = self.messages[indexPath.item]
        self.messages.removeAtIndex(indexPath.item)
        firebase!.childByAppendingPath("messages/\(message.messageId!)").removeValue()
    }
    
    // MARK: - UICollectionViewDatasource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.messages[indexPath.item]
        return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
}
