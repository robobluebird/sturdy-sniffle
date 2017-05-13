//
//  Account.swift
//  tel
//
//  Created by robobluebird on 4/25/17.
//  Copyright © 2017 bitewolf. All rights reserved.
//

import UIKit
import SwiftyJSON

class Account: NSObject {
  var id: Int
  var handle: String
  
  override init() {
    self.id = 0
    self.handle = ""
  }
  
  init?(id: Int, handle: String) {
    self.id = id
    self.handle = handle
  }
}
