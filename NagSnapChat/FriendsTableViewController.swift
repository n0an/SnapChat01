//
//  FriendsTableViewController.swift
//  NagSnapChat
//
//  Created by nag on 17.09.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

class FriendsTableViewController: UITableViewController {
    
    struct Storyboard {
        static let cellIdentifier = "Friend Cell"
        static let showEditFriendsSegue = "Show Edit Friends"
    }
    

    var friends = [PFUser]()
    var currentUser: PFUser!
    var friendsRelation: PFRelation!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchFriends()
    }
    
    func fetchFriends() {
        currentUser = PFUser.currentUser()!
        
        if let friendsRelation = currentUser["friendsRelation"] as? PFRelation {
            let friendsQuery = friendsRelation.query()
            friendsQuery.orderByAscending("username")
            
            friendsQuery.findObjectsInBackgroundWithBlock({ (friends, error) in
                if error == nil {
                    self.friends = friends as! [PFUser]
                    self.tableView.reloadData()
                } else {
                    print(error)
                }
            })
        }
    }
    
    
    // MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellIdentifier, forIndexPath: indexPath)
        
        let friend = self.friends[indexPath.row]
        
        cell.textLabel?.text = friend.username
        
        return cell
    }

    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

}







