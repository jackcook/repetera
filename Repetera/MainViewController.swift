//
//  MainViewController.swift
//  Repetera
//
//  Created by Jack Cook on 10/3/15.
//  Copyright © 2015 Jack Cook. All rights reserved.
//

import RealmSwift
import UIKit

public class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var names: Array<String>!
    var subscriptions: Array<Subscription>!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        var accessTokens = Array<String>()
        
        for account in (try! Realm()).objects(Account) {
            if !accessTokens.contains(account.accessToken) {
                accessTokens.append(account.accessToken)
            }
        }
        
        self.names = Array<String>()
        self.subscriptions = Array<Subscription>()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .None
        
        for token in accessTokens {
            Plaid.connect(token, completion: { (accounts, transactions, error) -> Void in
                guard let transactions = transactions else {
                    print("an error occurred :(")
                    return
                }
                
                for transaction in transactions {
                    if let subscription = Subscription.getSubscriptions()[transaction.name] {
                        if !self.names.contains(transaction.name) {
                            self.names.append(transaction.name)
                            self.subscriptions.append(subscription)
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    func getTransactionsByAccount(account: Account, transactions: Array<Transaction>) -> Array<Transaction> {
        var newTransactions = Array<Transaction>()
        
        for transaction in transactions {
            if transaction.account == account.id {
                newTransactions.append(transaction)
            }
        }
        
        return newTransactions
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionCell", forIndexPath: indexPath)
        
        let subscription = self.subscriptions[indexPath.row]
        
        let background = cell.viewWithTag(10)!
        background.layer.cornerRadius = 8
        background.backgroundColor = subscription.color
        
        let icon = cell.viewWithTag(11)! as! UIImageView
        icon.image = UIImage(named: subscription.name)
        
        let name = cell.viewWithTag(12)! as! UILabel
        name.text = subscription.name
        
        let status = cell.viewWithTag(13)! as! UILabel
        status.text = subscription.status!.uppercaseString
        
        let price = cell.viewWithTag(14)! as! UILabel
        price.text = "$" + String(format: "%.2f", subscription.price!)
        
        return cell
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subscriptions.count
    }
}
