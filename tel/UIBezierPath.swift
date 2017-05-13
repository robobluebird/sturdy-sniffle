//
//  UIBezierPath.swift
//  tel
//
//  Created by robobluebird on 4/30/17.
//  Copyright © 2017 bitewolf. All rights reserved.
//

import UIKit

extension UIBezierPath {
  convenience init(circleSegmentCenter center:CGPoint, radius:CGFloat, startAngle:CGFloat, endAngle:CGFloat)
  {
    self.init()
    self.move(to: center)
    self.addArc(withCenter: center, radius:radius, startAngle:startAngle.radians(), endAngle: endAngle.radians(), clockwise:true)
    self.close()
  }
}
