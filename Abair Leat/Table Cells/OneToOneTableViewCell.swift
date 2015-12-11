//
//  OneToOneTableViewCell.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 30/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import UIKit
import Firebase
class OneToOneTableViewCell: UITableViewCell, ChatsListTableViewControllerCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var otherPersonsName: UILabel!
    @IBOutlet weak var lastChatMessage: UILabel!
    @IBOutlet weak var dateLastMessageSent: UILabel!
    
    override func awakeFromNib() {
        self.contentView.backgroundColor = UIColor.clearColor()
        self.contentView.opaque = false
        self.contentView.superview?.backgroundColor = UIColor.clearColor()
        self.contentView.superview?.opaque = false
    }
    
    func setup(conversation: ConversationMetadata) {
        let me = AbairLeat.shared.profile.me!
        let theirIndex = conversation.participants.indexOf({$0.1.id != me.id})!
        let them = conversation.participants[theirIndex].1
        
        self.avatar.hnk_setImageFromURL(NSURL(string: them.avatarUrlString)!)
        self.otherPersonsName.text = them.name
        
        self.lastChatMessage.text = conversation.lastMessageSent
        if let sentDate = conversation.dateLastMessageSent {
            self.dateLastMessageSent.text = sentDate.occuredToday() ? sentDate.toShortTimeStyle() : sentDate.toShortDateStyle()
        } else {
            self.dateLastMessageSent.text = ""
        }
    }
    
}
