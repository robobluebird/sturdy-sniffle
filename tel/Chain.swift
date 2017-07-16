//
//  Chain.swift
//  tel
//
//  Created by robobluebird on 10/10/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit
import SwiftyJSON

class Chain: NSObject {
  var id = ""
  var url: String?
  var duration = Float(0.0)
  var code: String = ""
  var sounds = [Sound]()
  var queuedBuildCount = 0
  var isStarred = false
  
  init(sounds: [Sound]) {
    self.sounds = sounds
    
    var newDuration = Float(0.0)
    
    sounds.forEach({ sound in
      newDuration += sound.duration
    })
    
    self.duration = newDuration
  }
  
  init?(json: JSON) {
    id = json["id"].stringValue
    url = json["url"].string ?? ""
    code = json["code"].stringValue
    duration = json["duration"].float ?? 0.0
    queuedBuildCount = json["queued_build_count"].int ?? 0
    isStarred = json["starred"].boolValue
    sounds = json["sounds"].array!.map { item in Sound(json: item)! }
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
