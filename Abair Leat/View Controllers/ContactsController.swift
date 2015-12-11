//
//  ContactsController.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 27/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import UIKit
import Firebase

//
// Lists the user's facebook friends. Tapping on a friend jumps to a conversation
//
class ContactsController: FirebaseTableViewController, FirebaseTableViewControllerDatasourceDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.datasourceDelegate = self
        self.firebaseRef = AbairLeat.shared.contacts.myContactsRef()!.queryOrderedByPriority()
        self.firebaseRef!.keepSynced(true)
    }
    
    // MARK: - FirebaseTableViewControllerDatasourceDelegate
    
    // note the superclass will follow links in our datasource to only give us profiles here
    func deserialise(snapshot: FDataSnapshot, callback: (Any) -> Void) {
        let profile = snapshot.value as! NSDictionary
        callback(Profile(firebaseSnapshot: profile))
    }
    
    func cellForRow(tableView: UITableView, indexPath: NSIndexPath, item: Any) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contact_cell", forIndexPath: indexPath) as! ContactTableViewCell
        cell.setup(item as! Profile)
        return cell
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?, item: Any) {
        let conversationController = segue.destinationViewController as! ConversationController
        conversationController.hidesBottomBarWhenPushed = true
        conversationController.conversationId = AbairLeat.shared.conversations.createOneToOneConversation((item as! Profile).id) 
    }
    
}