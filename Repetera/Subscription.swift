//
//  Subscription.swift
//  Repetera
//
//  Created by Jack Cook on 10/3/15.
//  Copyright © 2015 Jack Cook. All rights reserved.
//

import SwiftyJSON
import UIKit

public class Subscription {
    
    public var id: String!
    public var price: Float!
    
    init(id: String, price: Float) {
        self.id = id
        self.price = price
    }
    
    public func getColor() -> UIColor {
        return Subscription.colorForSubscriptionID(self.id)
    }
    
    public func getName() -> String {
        return Subscription.nameForSubscriptionID(self.id)
    }
    
    public func getStatus() -> String {
        return Subscription.statusForSubscriptionID(self.id, price: self.price)
    }
    
    private class func colorForSubscriptionID(id: String) -> UIColor {
        let subscriptions = Subscription.getSubscriptions()
        var subscription: Dictionary<String, AnyObject>?
        
        for expression in subscriptions.keys {
            let sub = subscriptions[expression]!
            
            let regex = try! NSRegularExpression(pattern: expression,
                options: [.AnchorsMatchLines])
            let match = regex.firstMatchInString(id, options: [], range: NSMakeRange(0, NSString(string: id).length)) != nil
            
            if match {
                subscription = sub
            }
        }
        
        if let subscription = subscription {
            let colorString = subscription["color"]!
            let stringComponents = colorString.componentsSeparatedByString(",")
            let components = stringComponents.map({ CGFloat(Int($0)!) })
            
            return UIColor(red: components[0] / 255, green: components[1] / 255, blue: components[2] / 255, alpha: 1)
        } else {
            return UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
        }
    }
    
    private class func nameForSubscriptionID(id: String) -> String {
        let subscriptions = Subscription.getSubscriptions()
        var subscription: Dictionary<String, AnyObject>?
        
        for expression in subscriptions.keys {
            let sub = subscriptions[expression]!
            
            let regex = try! NSRegularExpression(pattern: expression,
                options: [.AnchorsMatchLines])
            let match = regex.firstMatchInString(id, options: [], range: NSMakeRange(0, NSString(string: id).length)) != nil
            
            if match {
                subscription = sub
            }
        }
        
        if let subscription = subscription {
            return subscription["name"]! as! String
        } else {
            return id
        }
    }
    
    private class func statusForSubscriptionID(id: String, price: Float) -> String {
        let subscriptions = Subscription.getSubscriptions()
        var subscription: Dictionary<String, AnyObject>?
        
        for expression in subscriptions.keys {
            let sub = subscriptions[expression]!
            
            let regex = try! NSRegularExpression(pattern: expression,
                options: [.AnchorsMatchLines])
            let match = regex.firstMatchInString(id, options: [], range: NSMakeRange(0, NSString(string: id).length)) != nil
            
            if match {
                subscription = sub
            }
        }
        
        if let subscription = subscription {
            let statuses = subscription["statuses"]! as! Dictionary<String, String>
            if let all = statuses["*"] {
                return all
            } else {
                let cost = String(format: "%.2f", price)
                return statuses[cost]!
            }
        } else {
            return "Unknown"
        }
    }
    
    public class func getSubscriptions() -> Dictionary<String, Dictionary<String, AnyObject>> {
        let path = NSBundle.mainBundle().pathForResource("Subscriptions", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path) as! Dictionary<String, Dictionary<String, AnyObject>>
        
        return dict
    }
}
