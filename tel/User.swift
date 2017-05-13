//
//  User.swift
//  tel
//
//  Created by robobluebird on 10/10/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject {
  var id: Int
  var handle: String
  var email: String
  var color: String
  var approvedUsers = [Int]()
  var apiKey: String?
  var imageUrl: String?
  
  override init() {
    self.id = 0
    self.handle = ""
    self.email = ""
    self.color = ""
  }
  
  init?(id: Int, handle: String, email: String?, color: String?) {
    self.id = id
    self.handle = handle
    self.email = email!
    self.color = color!
  }
  
  init?(json: JSON) {
    id = json["id"].int!
    handle = json["handle"].string!
    email = json["email"].string!
    color = json["color"].string!
    apiKey = json["api_key"].string
    imageUrl = json["image_url"].string
    
    if let users = json["approved_users"].array {
      approvedUsers = users.map { $0.int! }
    }
  }
  
  // MARK: NSCoding
  
  required init(coder decoder: NSCoder) {
    //Error here "missing argument for parameter name in call
    id = decoder.decodeInteger(forKey: "id")
    handle = decoder.decodeObject(forKey: "handle") as! String
    email = decoder.decodeObject(forKey: "email") as! String
    color = decoder.decodeObject(forKey: "color") as! String
    apiKey = decoder.decodeObject(forKey: "apiKey") as? String
    imageUrl = decoder.decodeObject(forKey: "imageUrl") as? String
    approvedUsers = decoder.decodeObject(forKey: "approvedUsers") as! [Int]
    
    super.init()
  }
  
  func encodeWithCoder(_ coder: NSCoder) {
    coder.encode(id, forKey: "id")
    coder.encode(handle, forKey: "handle")
    coder.encode(email, forKey: "email")
    coder.encode(color, forKey: "color")
    coder.encode(apiKey, forKey: "apiKey")
    coder.encode(imageUrl, forKey: "imageUrl")
    coder.encode(approvedUsers, forKey: "approvedUsers")
  }
}
