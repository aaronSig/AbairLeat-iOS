//
//  ChatsListTableViewController.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 30/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import UIKit
import Firebase

protocol ChatsListTableViewControllerCell {
    func setup(conversation: ConversationMetadata)
}

class ChatsListTableViewController: FirebaseTableViewController, FirebaseTableViewControllerDatasourceDelegate {
    
    static let ONE_TO_ONE_CELL = "one_to_one_cell"
    static let GROUP_CELL = "group_cell"
    let gradient: CAGradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.datasourceDelegate = self
        self.firebaseRef = AbairLeat.shared.profile.myProfileRef!.childByAppendingPath("conversations-metadata").queryOrderedByPriority()
        self.firebaseRef!.keepSynced(true)
    }
    
    
    // MARK: - FirebaseTableViewControllerDatasourceDelegate
    func deserialise(snapshot: FDataSnapshot, callback: (Any) -> Void) {
        let metadata = snapshot.value as! NSDictionary
        let participantIds = metadata["participants"] as? [String]
        var participants = [String: Profile]()
        if let participantIds = participantIds {
            for id in participantIds {
                AbairLeat.shared.profile.profileRefForUser(id).observeSingleEventOfType(.Value, withBlock: { (profileSnapshot) -> Void in
                    let participant = Profile(firebaseSnapshot: profileSnapshot.value as! NSDictionary)
                    participants[participant.id] = participant
                    if participants.count == participantIds.count {
                        let conversation = ConversationMetadata(firebaseSnapshot: metadata, participants: participants)
                        callback(conversation)
                    }
                })
            }
        }
    }
    
    func cellForRow(tableView: UITableView, indexPath: NSIndexPath, item: Any) -> UITableViewCell {
        let conversation = item as! ConversationMetadata
        let identifier = conversation.isOneToOne ? ChatsListTableViewController.ONE_TO_ONE_CELL : ChatsListTableViewController.GROUP_CELL
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! ChatsListTableViewControllerCell
        cell.setup(item as! ConversationMetadata)
        return cell as! UITableViewCell
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?, item: Any) {
        let conversationController = segue.destinationViewController as! ConversationController
        conversationController.hidesBottomBarWhenPushed = true
        conversationController.conversationId = (item as! ConversationMetadata).conversationId
    }
    
    
    // MARK: - animated gradient
    
    let switchOnAnimation = false
    override func viewWillAppear(animated: Bool) {
        if switchOnAnimation {
            setupAnimation()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if switchOnAnimation {
            self.animateLayer()
        }
    }
    
    func setupAnimation() {
        self.view.backgroundColor = UIColor.clearColor()
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.superview?.backgroundColor = UIColor.clearColor()
        gradient.frame = self.view.bounds
        self.gradient.colors = [UIColor.purpleColor().CGColor, UIColor.redColor().CGColor]
        self.navigationController?.view.layer.insertSublayer(self.gradient, atIndex: 0)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }

    func animateLayer() {
        let fromColours = [UIColor.purpleColor().CGColor, UIColor.redColor().CGColor]
        let toColours = [UIColor.orangeColor().CGColor, UIColor.yellowColor().CGColor]
        self.gradient.colors = toColours
        
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = fromColours
        animation.toValue = toColours
        animation.duration = 10.0
        animation.removedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.delegate = self
        animation.repeatCount = Float.infinity
        animation.autoreverses = true
        
        self.gradient.addAnimation(animation, forKey: "gradientTransition")
    }
    

}