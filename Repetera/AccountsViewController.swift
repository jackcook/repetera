//
//  AccountsViewController.swift
//  Repetera
//
//  Created by Jack Cook on 10/3/15.
//  Copyright © 2015 Jack Cook. All rights reserved.
//

import RealmSwift
import UIKit

public class AccountsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var accounts: Array<Account>!
    
    @IBOutlet weak var tableView: UITableView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.accounts = Array<Account>()
        
        for account in (try! Realm()).objects(Account) {
            self.accounts.append(account)
        }
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.allowsSelection = false
    }
    
    @IBAction func backButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountCell")!
        
        let nameLabel = cell.viewWithTag(11)! as! UILabel
        nameLabel.text = self.accounts[indexPath.row].name
        
        return cell
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
}
