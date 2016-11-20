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
    
    // MARK: - PROPERTIES
    
    struct Storyboard {
        static let cellIdentifier = "Friend Cell"
        static let showEditFriendsSegue = "Show Edit Friends"
    }
    
    var friends = [PFUser]()
    var currentUser: PFUser!
    var friendsRelation: PFRelation<PFObject>!
    
    
    // MARK: - viewWillAppear

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchFriends()
    }
    
    // MARK: - HELPER METHODS
    
    func fetchFriends() {
        currentUser = PFUser.current()!
        
        if let friendsRelation = currentUser["friendsRelation"] as? PFRelation {
            let friendsQuery = friendsRelation.query()
            friendsQuery.order(byAscending: "username")
            
            friendsQuery.findObjectsInBackground(block: { (friends, error) in
                if error == nil {
                    self.friends = friends as! [PFUser]
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
    }
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.showEditFriendsSegue {
            let editFriendsVC = segue.destination as! EditFriendsTableViewController
            editFriendsVC.friends = self.friends
        }
    }
    
    
    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.cellIdentifier, for: indexPath)
        
        let friend = self.friends[indexPath.row]
        
        cell.textLabel?.text = friend.username
        
        return cell
    }

    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
    }

}







