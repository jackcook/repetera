//
//  Transaction.swift
//  Repetera
//
//  Created by Jack Cook on 10/4/15.
//  Copyright © 2015 Jack Cook. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Transaction {
    
    var account: String
    var id: String
    var amount: Float
    var date: NSDate
    var name: String
    var processor: String
    var pending: Bool
    var categories: Array<String>
    
    init(json: JSON) {
        self.account = json["_account"].stringValue
        self.id = json["_id"].stringValue
        self.amount = json["amount"].floatValue
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.date = formatter.dateFromString(json["date"].stringValue)!
        
        self.name = json["name"].stringValue
        self.processor = json["meta"]["payment_processor"].stringValue
        self.pending = json["pending"].boolValue
        
        self.categories = Array<String>()
        let categories = json["category"].arrayValue
        for category in categories {
            self.categories.append(category.stringValue)
        }
    }
}
