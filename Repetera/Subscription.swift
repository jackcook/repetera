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
    
    public var name: String!
    public var color: UIColor!
    public var status: String?
    public var price: Float?
    
    init(info: JSON) {
        self.name = info["name"].stringValue
        
        let colorString = info["color"].stringValue
        let stringComponents = colorString.componentsSeparatedByString(",")
        let components = stringComponents.map({ CGFloat(Int($0)!) })
        self.color = UIColor(red: components[0] / 255, green: components[1] / 255, blue: components[2] / 255, alpha: 1)
        
        if let status = info["status"].string {
            self.status = status
        }
        
        if let price = info["price"].string {
            self.price = Float(price)
        }
    }
    
    public class func getSubscriptions() -> Dictionary<String, Subscription> {
        let path = NSBundle.mainBundle().pathForResource("Subscriptions", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path) as! Dictionary<String, Dictionary<String, String>>
        
        var subscriptions = Dictionary<String, Subscription>()
        
        for (key, value) in dict {
            let subscription = Subscription(info: JSON(value))
            subscriptions[key] = subscription
        }
        
        return subscriptions
    }
}
