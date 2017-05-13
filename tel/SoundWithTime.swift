//
//  SoundWithTime.swift
//  tel
//
//  Created by robobluebird on 10/10/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit
import SwiftyJSON

class SoundWithTime: NSObject {
  var sound: Sound
  var startTime: Float?
  var position: Int?
  
  override init() {
    sound = Sound()
    startTime = nil
    position = 0
  }
  
  init?(json: JSON) {
    sound = Sound(json: json["sound"])!
    startTime = json["start_time"].float
    position = json["position"].int
  }
}
