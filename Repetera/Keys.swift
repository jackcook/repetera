//
//  Keys.swift
//  Chipmunk
//
//  Created by Jack Cook on 9/19/15.
//  Copyright © 2015 Jack Cook. All rights reserved.
//

import Foundation

public class Keys {
    
    public class func bankUsername() -> String {
        return Keys.getKey("Username")
    }
    
    public class func bankPassword() -> String {
        return Keys.getKey("Password")
    }
    
    public class func bankType() -> String {
        return Keys.getKey("Institution")
    }
    
    public class func plaidClientID() -> String {
        return Keys.getKey("PlaidClientID")
    }
    
    public class func plaidClientSecret() -> String {
        return Keys.getKey("PlaidClientSecret")
    }
    
    public class func getKey(key: String) -> String {
        let path = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path) as! [String: String]
        
        return dict[key]!
    }
}
