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
        return Subscription.statusForSubscriptionID(self.id)
    }
    
    private class func colorForSubscriptionID(id: String) -> UIColor {
        let subscriptions = Subscription.getSubscriptions()
        if let subscription = subscriptions[id] {
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
        if let subscription = subscriptions[id] {
            return subscription["name"]!
        } else {
            return id
        }
    }
    
    private class func statusForSubscriptionID(id: String) -> String {
        let subscriptions = Subscription.getSubscriptions()
        if let subscription = subscriptions[id] {
            return subscription["status"]!
        } else {
            return "Unknown"
        }
    }
    
    public class func getSubscriptions() -> Dictionary<String, Dictionary<String, String>> {
        let path = NSBundle.mainBundle().pathForResource("Subscriptions", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path) as! Dictionary<String, Dictionary<String, String>>
        
        return dict
    }
}
