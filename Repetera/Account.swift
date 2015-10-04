//
//  Account.swift
//  Repetera
//
//  Created by Jack Cook on 10/3/15.
//  Copyright © 2015 Jack Cook. All rights reserved.
//

import RealmSwift
import SwiftyJSON

public class Account: Object {
    
    public dynamic var id = ""
    public dynamic var name = ""
    public dynamic var bank = ""
    public dynamic var accessToken = ""
}
