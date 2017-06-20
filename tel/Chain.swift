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
  var id: String
  var text: String
  var url: String?
  var duration: Float
  var code: String
  var sounds = [Sound]()
  var soundsWithTimes = [SoundWithTime]()
  var queuedBuildCount: Int
  
  override init() {
    id = ""
    text = ""
    url = ""
    code = ""
    duration = 0.0
    queuedBuildCount = 0
  }
  
  init?(json: JSON) {
    id = json["id"].string!
    text = json["description"].string ?? ""
    url = json["url"].string ?? ""
    code = json["code"].string!
    duration = json["duration"].float ?? 0.0
    queuedBuildCount = json["queued_build_count"].int ?? 0
    
    sounds = json["sounds"].array!.map { item in Sound(json: item)! }
    
    if let swt = json["sounds_with_times"].array {
      soundsWithTimes = swt.map { item in SoundWithTime(json: item)! }
    }
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
