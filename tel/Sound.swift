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
  var id = ""
  var url = ""
  var duration = Float(0.0)
  var position = -1
  var color = ""
  var token = ""
  
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
    color = json["color"].string ?? ""
    token = json["token"].string ?? ""
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
