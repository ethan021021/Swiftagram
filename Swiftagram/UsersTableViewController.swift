//
//  UsersTableViewController.swift
//  Swiftagram
//
//  Created by Ethan Thomas on 8/29/16.
//  Copyright © 2016 Ethan Thomas. All rights reserved.
//

import UIKit
import Parse

class UsersTableViewController: UITableViewController {
    
    var usernames = [String]()
    var userIDs = [String]()
    var isFollowing = [String: Bool]()
    
    var refresher: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        refresh()
        
        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refresher.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        
        tableView.addSubview(refresher)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        let query = PFUser.query()
        
        query?.findObjectsInBackground(block: { objs, error in
            if let err = error {
                print(err.localizedDescription)
            } else if let users = objs {
                
                self.usernames.removeAll()
                self.userIDs.removeAll()
                self.isFollowing.removeAll()
                
                for obj in users {
                    if let user = obj as? PFUser {
                        if user.objectId != PFUser.current()?.objectId {
                            let usernameArray = user.username!.components(separatedBy: "@")
                            self.usernames.append(usernameArray[0])
                            self.userIDs.append(user.objectId!)
                            
                            let query = PFQuery(className: "Followers")
                            
                            query.whereKey("follower", equalTo: PFUser.current()!.objectId!)
                            
                            query.whereKey("following", equalTo: user.objectId!)
                            
                            query.findObjectsInBackground(block: { (objects, error) in
                                if let objects = objects {
                                    if objects.count > 0 {
                                        self.isFollowing[user.objectId!] = true
                                    } else {
                                        self.isFollowing[user.objectId!] = false
                                    }
                                    
                                    if self.isFollowing.count == self.usernames.count {
                                        self.tableView.reloadData()
                                        
                                        self.refresher.endRefreshing()
                                    }
                                }
                            })
                        }
                    }
                }
            }
        })
    }
    
    
    @IBAction func logoutBtnPressed(_ sender: AnyObject) {
        PFUser.logOut()
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = usernames[indexPath.row]
        
        if isFollowing[userIDs[indexPath.row]]! {
            cell.accessoryType = .checkmark
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if isFollowing[userIDs[indexPath.row]]! {
            
            isFollowing[userIDs[indexPath.row]] = false
            
            cell?.accessoryType = .none
            let query = PFQuery(className: "Followers")
            query.whereKey("follower", equalTo: PFUser.current()!.objectId!)
            query.whereKey("following", equalTo: userIDs[indexPath.row])
            
            query.findObjectsInBackground(block: { (objects, error) in
                if let objects = objects {
                    for object in objects {
                        object.deleteInBackground()
                    }
                }
            })
        } else {
            isFollowing[userIDs[indexPath.row]] = true
            cell?.accessoryType = .checkmark
            let following = PFObject(className: "Followers")
            following["follower"] = PFUser.current()!.objectId
            following["following"] = userIDs[indexPath.row]
            
            following.saveInBackground()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
