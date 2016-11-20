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
    
    
    // MARK: - PROPERTIES
    
    let cellAccessoryColor = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
    
    var friends = [PFUser]()
    fileprivate var users = [PFUser]()
    
    fileprivate var currentUser = PFUser.current()!
    
    struct Storyboard {
        static let cellIdentifier = "Friend Cell"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Friends"
        
        fetchUsers()

        
    }
    
    // MARK: - HELPER METHODS
    
    fileprivate func fetchUsers() {
        let userQuery = PFUser.query()
        userQuery?.order(byAscending: "username")
        userQuery?.findObjectsInBackground(block: { (users, error) in
            
            if error == nil {
                self.users = users as! [PFUser]
                self.tableView.reloadData()
            } else {
                
                let alertVC = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alertVC.addAction(okAction)
                
                self.present(alertVC, animated: true, completion: nil)
                

                print(error)
            }
            
        })
    }
    
    fileprivate func isFriendWith(_ user: PFUser) -> Bool {
        
        for friend in friends {
            if friend.objectId == user.objectId {
                return true
            }
        }
        
        return false
        
    }
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdentifier, for: indexPath)
        
        let user = self.users[indexPath.row]
        
        cell.textLabel?.text = user.username
        
        if isFriendWith(user) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let user = self.users[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath)
        
        let friendsRelation = currentUser.relation(forKey: "friendsRelation")

        
        if isFriendWith(user) {
            // unfriend
            cell?.accessoryType = .none
            
            for friend in self.friends {
                if friend.objectId == user.objectId {
                    let indexToRemove = self.friends.index(of: friend)
                    self.friends.remove(at: indexToRemove!)
                }
            }
            

            
            friendsRelation.remove(user)
            
        } else {
            // add friendship
            cell?.accessoryType = .checkmark
            
            friends.append(user)
            
            friendsRelation.add(user)
        }
        
        
        
        
        
        currentUser.saveInBackground { (success, error) in
            if error != nil {
                print(error)
            }
        }
    }


    

}











