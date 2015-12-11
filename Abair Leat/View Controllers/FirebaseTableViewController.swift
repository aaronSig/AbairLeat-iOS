//
//  FirebaseTableViewController.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 07/12/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import UIKit
import Firebase

protocol FirebaseTableViewControllerDatasourceDelegate {
    func cellForRow(tableView: UITableView, indexPath: NSIndexPath, item: Any) -> UITableViewCell
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?, item: Any)
    func deserialise(snapshot: FDataSnapshot, callback:(Any)->Void)
}

// A controller handy for working with Firebase 1 dimensional arrays of data.
// Supports downloading, adding and deleting items. Not move.
class FirebaseTableViewController: UITableViewController {

    var firebaseRef: FQuery? {
        didSet {
            if let firebase = firebaseRef {
                self.initalLoadAndAttach(firebase);
            }
        }
    }
    
    var datasourceDelegate: FirebaseTableViewControllerDatasourceDelegate?
    
    var items = [FDataSnapshot]()
    var userItems = [Any]()
    
    func initalLoadAndAttach(ref: FQuery) {
        // first time fetch all the data in bulk
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            var childrenCount = snapshot.childrenCount
            if childrenCount == 0 {
                self.attachObservers(ref)
            }
            while let child: AnyObject = enumerator.nextObject() {
                self.deserialiseFollowingLinks(child as! FDataSnapshot, callback: { (userItem) -> Void in
                    self.items.append(child as! FDataSnapshot)
                    self.userItems.append(userItem)
                    childrenCount -= 1
                    if childrenCount == 0 {
                        self.tableView.reloadData()
                        self.attachObservers(ref)
                    }
                })
            }
        })
    }
    
    deinit {
        self.firebaseRef?.removeAllObservers()
    }
    
    func attachObservers(ref: FQuery) {
        ref.observeEventType(.ChildAdded, withBlock: { (childSnapshot) -> Void in
            if self.items.contains({$0.key == childSnapshot.key}) {
                // we alredy have this item
                return
            }
            
            self.deserialiseFollowingLinks(childSnapshot, callback: { (userItem) -> Void in
                self.items.append(childSnapshot)
                self.userItems.append(userItem)
                self.insertRowAtIndex(self.items.count - 1)
            })
            
        })
        
        ref.observeEventType(.ChildRemoved, withBlock: { (childSnapshot) -> Void in
            // find the item if it exists in our array and remove it
            if let idx = self.items.indexOf({$0.key == childSnapshot.key}){
                self.items.removeAtIndex(idx)
                self.userItems.removeAtIndex(idx)
                self.removeRowAtIndex(idx)
            }
        })
        
        ref.observeEventType(.ChildChanged, withBlock: { (childSnapshot) -> Void in
            // find the item if it exists in our array and update it
            if let idx = self.items.indexOf({$0.key == childSnapshot.key}){
                self.deserialiseFollowingLinks(childSnapshot, callback: { (userItem) -> Void in
                    self.items[idx] = childSnapshot
                    self.userItems[idx] = userItem
                    self.reloadRowAtIndex(idx)
                })
            }
        })
        
        ref.observeEventType(.ChildMoved, andPreviousSiblingKeyWithBlock: { (childSnapshot, previousKey) -> Void in
            let currentIndex = self.items.indexOf({$0.key == childSnapshot.key})!
            let item = self.items.removeAtIndex(currentIndex)
            let userItem = self.userItems.removeAtIndex(currentIndex)
            
            // if previousKey == null then this has been moved to the top
            var nextIndex = 0
            if let previousKey = previousKey {
                let previousKeyIndex = self.items.indexOf({$0.key == previousKey})!
                nextIndex = previousKeyIndex + 1
            }
            self.items.insert(item, atIndex: nextIndex)
            self.userItems.insert(userItem, atIndex: nextIndex)
            
            self.moveRowAtIndex(currentIndex, toIndex: nextIndex)
        })
    }
    
    func deserialiseFollowingLinks(snapshot: FDataSnapshot, callback:(Any)->Void) {
        if snapshot.isALink() {
            // we need to watch this items for changes now only calling deserialise on change and updating the item in the index if it changes.
            var storedCallback:((Any)->Void)? = callback
            var pathComponents:[String] = snapshot.linkPathComponents()
            pathComponents.popLast()
            let linkPrefix = FDataSnapshot.linkify(pathComponents)
            snapshot.linkToRef().observeEventType(.Value, withBlock: { (update) -> Void in
                if update.exists() == false {
                    print("WARNING: there is a link that has a null destination.", snapshot.key)
                    return
                }
                
                self.datasourceDelegate?.deserialise(update, callback: { (deserialisedUserItem) -> Void in
                    if let cb = storedCallback {
                        // only use the callback once or it can mess up the table
                        storedCallback = nil
                        cb(deserialisedUserItem)
                        return
                    }
                    // need to update the item in the userList. Treat as a .ChildChanged
                    // note the item keys will have the link prefix
                    let linkKey = "\(linkPrefix)>\(update.key)"
                    if let idx = self.items.indexOf({$0.key == linkKey}){
                        self.userItems[idx] = deserialisedUserItem
                        self.reloadRowAtIndex(idx)
                    }
                })
            })
        } else {
            //hand off to the delegate
            self.datasourceDelegate?.deserialise(snapshot, callback: callback)
        }
    }
    
    func insertRowAtIndex(idx: Int) {
        self.tableView!.insertRowsAtIndexPaths([NSIndexPath(forRow: idx, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func removeRowAtIndex(idx: Int) {
        self.tableView!.deleteRowsAtIndexPaths([NSIndexPath(forRow: idx, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func reloadRowAtIndex(idx: Int) {
        self.tableView!.reloadRowsAtIndexPaths([NSIndexPath(forRow: idx, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func moveRowAtIndex(idx: Int, toIndex: Int) {
        self.tableView!.moveRowAtIndexPath(NSIndexPath(forRow: idx, inSection: 0), toIndexPath: NSIndexPath(forRow: toIndex, inSection: 0))
    }
    
    func userItemForIndexPath(indexPath: NSIndexPath) -> Any {
        return self.userItems[indexPath.row]
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.datasourceDelegate!.cellForRow(tableView, indexPath: indexPath, item: self.userItemForIndexPath(indexPath))
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let selectedRow = self.tableView.indexPathForSelectedRow!
        self.tableView.deselectRowAtIndexPath(selectedRow, animated: true)
        self.datasourceDelegate?.prepareForSegue(segue, sender: sender, item: self.userItemForIndexPath(selectedRow))
    }
    
}
