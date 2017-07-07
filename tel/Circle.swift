//
//  Circle.swift
//  tel
//
//  Created by robobluebird on 5/9/17.
//  Copyright © 2017 bitewolf. All rights reserved.
//

import UIKit

class Circle: UIView {
  var currentAngle = CGFloat(0)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    layer.cornerRadius = frame.width / 2
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
    return pow(center.x-point.x, 2) + pow(center.y - point.y, 2) <= pow(bounds.size.width/2, 2)
  }
  
  func rotateTo(degreeAngle: CGFloat) {
    self.currentAngle = -degreeAngle
    rotate()
  }
  
  func rotateBy(degreeAngle: CGFloat) {
    self.currentAngle += degreeAngle
    rotate()
  }
  
  private func rotate() {
    self.transform = CGAffineTransform(rotationAngle: self.currentAngle * CGFloat(M_PI/180))
  }
}
