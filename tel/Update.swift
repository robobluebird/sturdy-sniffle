//
//  Update.swift
//  tel
//
//  Created by robobluebird on 10/10/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit
import SwiftyJSON

class Update: NSObject {
  var who: User
  var what: String
  var when: Date
  
  override init() {
    self.who = User()
    self.what = "hasn't been updated!"
    self.when = Date()
  }
  
  init?(json: JSON) {
    if json["who"] != nil {
      self.who = User(json: json["who"])!
    } else {
      self.who = User()
    }
    
    self.what = json["what"].string!
    self.when = Date(timeIntervalSince1970: json["when"].double!)
  }
}
