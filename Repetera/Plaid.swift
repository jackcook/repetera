//
//  Plaid.swift
//  Chipmunk
//
//  Created by Jack Cook on 9/19/15.
//  Copyright © 2015 Jack Cook. All rights reserved.
//

import Foundation
import SwiftyJSON

let client_id = Keys.plaidClientID()
let secret = Keys.plaidClientSecret()
var access_token = String()

public class Plaid {
    
    public static var accounts = Array<Account>()
    public static var transactions = Array<Transaction>()
    
    public class func authenticate(username: String, password: String, type: String, completion: (access_token: String?, error: NSError?) -> Void) {
        Plaid.request("/auth", requestType: "POST", params: ["client_id": client_id, "secret": secret, "username": username, "password": password, "type": type]) { (json, error) -> Void in
            if let _ = error {
                completion(access_token: nil, error: error)
            } else {
                let token = json["access_token"].stringValue
                access_token = token
                completion(access_token: token, error: nil)
            }
        }
    }
    
    public class func connect(access_token: String, completion: (accounts: Array<Account>?, transactions: Array<Transaction>?, error: NSError?) -> Void) {
        Plaid.request("/connect", requestType: "GET", params: ["client_id": client_id, "secret": secret, "access_token": access_token]) { (json, error) -> Void in
            if let _ = error {
                completion(accounts: nil, transactions: nil, error: error)
            } else {
                var accounts = Array<Account>()
                
                let retrieved_accounts = json["accounts"].arrayValue
                for retrieved_account in retrieved_accounts {
                    let account = Account(json: retrieved_account)
                    accounts.append(account)
                }
                
                var transactions = Array<Transaction>()
                
                let retrieved_transactions = json["transactions"].arrayValue
                for retrieved_transaction in retrieved_transactions {
                    let transaction = Transaction(json: retrieved_transaction)
                    transactions.append(transaction)
                }
                
                completion(accounts: accounts, transactions: transactions, error: nil)
            }
        }
    }
    
    public class func upgrade(access_token: String, completion: (error: NSError?) -> Void) {
        Plaid.request("/upgrade", requestType: "POST", params: ["client_id": client_id, "secret": secret, "access_token": access_token, "upgrade_to": "connect"]) { (json, error) -> Void in
            completion(error: error)
        }
    }
    
    private class func request(endpoint: String, requestType: String, params: Dictionary<String, String>, completion: (json: JSON, error: NSError?) -> Void) {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        var url = NSURL(string: "https://tartan.plaid.com\(endpoint)")!
        url = self.NSURLByAppendingQueryParameters(url, queryParameters: params)
        print(url)
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = requestType
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if data != nil {
                let json = JSON(data: data!)
                completion(json: json, error: error)
            } else {
                // offline
            }
        }
        
        task.resume()
    }
    
    private class func stringFromQueryParameters(queryParameters : Dictionary<String, String>) -> String {
        var parts: [String] = []
        for (name, value) in queryParameters {
            let part = NSString(format: "%@=%@",
                name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!,
                value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            parts.append(part as String)
        }
        return parts.joinWithSeparator("&")
    }
    
    private class func NSURLByAppendingQueryParameters(URL : NSURL!, queryParameters : Dictionary<String, String>) -> NSURL {
        let URLString: NSString = NSString(format: "%@?%@", URL.absoluteString, self.stringFromQueryParameters(queryParameters))
        return NSURL(string: URLString as String)!
    }
}

public struct Account {
    
    var id: String
    var user: String
    var available_balance: Float
    var current_balance: Float
    var bank: String
    var name: String
    var number: String
    var type: String
    
    init(json: JSON) {
        self.id = json["_id"].stringValue
        self.user = json["_user"].stringValue
        self.available_balance = json["balance"]["available"].floatValue
        self.current_balance = json["balance"]["current"].floatValue
        self.bank = json["institution_type"].stringValue
        self.name = json["meta"]["name"].stringValue
        self.number = json["meta"]["number"].stringValue
        self.type = json["subtype"].stringValue
    }
}

public class Transaction {
    
    var account: String
    var id: String
    var amount: Float
    var date: String
    var name: String
    var processor: String
    var pending: Bool
    
    init(json: JSON) {
        self.account = json["_account"].stringValue
        self.id = json["_id"].stringValue
        self.amount = json["amount"].floatValue
        self.date = json["date"].stringValue
        self.name = json["name"].stringValue
        self.processor = json["meta"]["payment_processor"].stringValue
        self.pending = json["pending"].boolValue
    }
}
