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
            
            let realm = try! Realm()
            realm.write {
                for account in accounts {
                    account.accessToken = access_token
                    realm.add(account)
                }
            }
            
            Plaid.upgrade(access_token, completion: { (error) -> Void in
                SVProgressHUD.dismiss()
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
}
