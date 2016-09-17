//
//  EditFriendsTableViewController.swift
//  NagSnapChat
//
//  Created by nag on 17.09.16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

class EditFriendsTableViewController: UITableViewController {
    
    var friends = [PFUser]()
    private var users = [PFUser]()
    
    private var currentUser = PFUser.currentUser()!
    
    struct Storyboard {
        static let cellIdentifier = "Friend Cell"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Friends"
        
        fetchUsers()

        
    }
    
    private func fetchUsers() {
        let userQuery = PFUser.query()
        userQuery?.orderByAscending("username")
        userQuery?.findObjectsInBackgroundWithBlock({ (users, error) in
            
            if error == nil {
                self.users = users as! [PFUser]
                self.tableView.reloadData()
            } else {
                print(error)
            }
            
        })
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellIdentifier, forIndexPath: indexPath)
        
        let user = self.users[indexPath.row]
        
        cell.textLabel?.text = user.username
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let user = self.users[indexPath.row]
        let friendsRelation = currentUser.relationForKey("friendsRelation")
        
        friendsRelation.addObject(user)
        currentUser.saveInBackgroundWithBlock { (success, error) in
            if error != nil {
                print(error)
            }
        }
    }


    

}











