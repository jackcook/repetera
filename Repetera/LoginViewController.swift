//
//  LoginViewController.swift
//  Repetera
//
//  Created by Jack Cook on 10/3/15.
//  Copyright © 2015 Jack Cook. All rights reserved.
//

import RealmSwift
import SVProgressHUD
import UIKit

public class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameField.text = ""
        self.passwordField.text = ""
    }
    
    @IBAction func backButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func submitButton(sender: UIButton) {
        let username = self.usernameField.text!
        let password = self.passwordField.text!
        
        SVProgressHUD.show()
        
        Plaid.authenticate(username, password: password, type: "chase") { (access_token, accounts, error) -> Void in
            guard let access_token = access_token, accounts = accounts else {
                print("an error occurred")
                return
            }
            
            Plaid.upgrade(access_token, completion: { (error) -> Void in
                
                Plaid.connect(access_token, completion: { (accounts, transactions, error) -> Void in
                    guard let transactions = transactions else {
                        print("errur")
                        return
                    }
                    
                    var transactionsDict = Dictionary<String, Array<Transaction>>()
                    
                    for transaction in transactions {
                        var fromDate: NSDate?
                        var toDate: NSDate?
                        let current = NSDate()
                        
                        let calendar = NSCalendar.currentCalendar()
                        calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: transaction.date)
                        calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: current)
                        
                        let difference = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: NSCalendarOptions(rawValue: 0))
                        print(difference.day)
                        if difference.day > 62 {
                            break
                        }
                        
                        if transactionsDict.keys.contains(transaction.name) {
                            transactionsDict[transaction.name]!.append(transaction)
                        } else {
                            transactionsDict[transaction.name] = Array<Transaction>()
                            transactionsDict[transaction.name]!.append(transaction)
                        }
                    }
                    
                    var subscriptions = Array<Subscription>()
                    
                    for key in transactionsDict.keys {
                        let transactions = transactionsDict[key]!
                        if transactions.count >= 2 {
                            let subscription = Subscription(id: transactions[0].name, price: transactions[0].amount)
                            subscriptions.append(subscription)
                        }
                    }
                    
                    SVProgressHUD.dismiss()
                })
            })
        }
    }
}
