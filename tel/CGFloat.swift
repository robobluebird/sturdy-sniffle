//
//  CGFloat.swift
//  tel
//
//  Created by robobluebird on 4/30/17.
//  Copyright © 2017 bitewolf. All rights reserved.
//

import UIKit

extension CGFloat {
  func radians() -> CGFloat {
    let b = CGFloat(M_PI) * ((self - 90) / 180)
    return b
  }
}
