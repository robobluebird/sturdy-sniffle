//
//  Sound.swift
//  tel
//
//  Created by robobluebird on 10/10/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit
import SwiftyJSON

class Sound: NSObject {
  var id: String
  var url: String
  var duration: Float
  var position: Int
  var color: String?
  
  override init() {
    id = ""
    url = ""
    duration = 0.0
    position = 0
    color = nil
  }
  
  init(position: Int, duration: Float, color: String) {
    id = ""
    url = ""
    self.duration = duration
    self.position = position
    self.color = color
  }
  
  init?(json: JSON) {
    id = json["id"].string!
    url = json["url"].string ?? ""
    duration = json["duration"].float ?? 0.0
    position = json["position"].int ?? 0
    color = json["color"].string
  }
  
  func displayTime() -> String {
    var minutes = 0
    var seconds = Int(duration)
    
    if (seconds >= 60) {
      let rest = seconds % 60
      minutes += (seconds - rest) / 60
      seconds = rest
    }
    
    let fm = String(format: "%02d", minutes)
    let fs = String(format: "%02d", seconds)
    return "\(fm):\(fs)"
  }
}
