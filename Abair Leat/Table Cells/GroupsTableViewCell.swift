//
//  GroupsTableViewCell.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 30/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import UIKit

class GroupsTableViewCell: UITableViewCell, ChatsListTableViewControllerCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var conversationName: UILabel!
    @IBOutlet weak var lastMessageSender: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var lastMessageSendTime: UILabel!
    
    func setup(conversation: ConversationMetadata) {
        // TODO
        
    }
    
}
