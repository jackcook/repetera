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
        self.tableView.allowsSelection = false
        
        for token in accessTokens {
            Plaid.connect(token, completion: { (accounts, transactions, error) -> Void in
                guard let transactions = transactions else {
                    print("errur")
                    return
                }
                
                var transactionsDict = Dictionary<String, Array<Transaction>>()
                
                for transaction in transactions {
                    if transaction.categories.contains("Interest") || transaction.categories.contains("Transfer") {
                        continue
                    }
                    
                    let difference = self.daysFrom(from: transaction.date, to: NSDate())
                    if difference > 62 {
                        break
                    }
                    
                    if transactionsDict.keys.contains(transaction.name) {
                        transactionsDict[transaction.name]!.append(transaction)
                    } else {
                        transactionsDict[transaction.name] = Array<Transaction>()
                        transactionsDict[transaction.name]!.append(transaction)
                    }
                }
                
                for key in transactionsDict.keys {
                    let transactions = transactionsDict[key]!
                    if transactions.count >= 2 {
                        var price: Float = 0.0
                        var first: NSDate?
                        var pass = false
                        
                        var i = 0
                        for transaction in transactions {
                            if i == 0 {
                                price = transaction.amount
                                first = transaction.date
                            } else {
                                if price != transaction.amount {
                                    break
                                }
                                
                                let days = self.daysFrom(from: transaction.date, to: first!)
                                if days <= 32 && days >= 28 {
                                    pass = true
                                    break
                                }
                            }
                            
                            i += 1
                        }
                        
                        if pass {
                            let subscription = Subscription(id: transactions[0].name, price: price)
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
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SubscriptionCell", forIndexPath: indexPath)
        
        let subscription = self.subscriptions[indexPath.row]
        
        let background = cell.viewWithTag(10)!
        background.layer.cornerRadius = 8
        background.backgroundColor = subscription.getColor()
        
        let icon = cell.viewWithTag(11)! as! UIImageView
        icon.image = UIImage(named: subscription.getStatus() == "Unknown" ? "Unknown" : subscription.getName())
        
        let name = cell.viewWithTag(12)! as! UILabel
        name.text = subscription.getName()
        
        let status = cell.viewWithTag(13)! as! UILabel
        status.text = subscription.getStatus().uppercaseString
        
        let price = cell.viewWithTag(14)! as! UILabel
        price.text = "$" + String(format: "%.2f", subscription.price!)
        
        return cell
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subscriptions.count
    }
    
    private func daysFrom(from pFromDate: NSDate, to pToDate: NSDate) -> Int {
        var fromDate: NSDate?
        var toDate: NSDate?
        
        let calendar = NSCalendar.currentCalendar()
        calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: pFromDate)
        calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: pToDate)
        
        let difference = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: NSCalendarOptions(rawValue: 0))
        return difference.day
    }
}
