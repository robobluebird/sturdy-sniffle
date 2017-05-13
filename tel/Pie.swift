//
//  Pie.swift
//  tel
//
//  Created by robobluebird on 4/29/17.
//  Copyright © 2017 bitewolf. All rights reserved.
//

import UIKit

class Pie: UIView {
  var chain: Chain?
  var progressLayer: CAShapeLayer?
  var outerDiameter: CGFloat?
  var innerDiameter: CGFloat?
  var piePieces = [(sound: Sound, startTime: Float, piece: CAShapeLayer, startAngle: CGFloat, endAngle: CGFloat)]()
  var centerX, centerY: CGFloat?
  
  init(chain: Chain, origin: (x: CGFloat, y: CGFloat), size: CGFloat) {
    let frame = CGRect(x: origin.x, y: origin.y, width: size, height: size)
    
    super.init(frame: frame)
    
    centerX = bounds.width / 2.0
    centerY = bounds.height / 2.0
    outerDiameter = size
    innerDiameter = size * 0.8
    
    backgroundColor = UIColor.black
    layer.cornerRadius = frame.width / 2
    
    self.chain = chain
    
    if self.chain!.duration > 0.0 && self.chain!.sounds.count > 0 {
      pieChartize()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
    return pow(center.x-point.x, 2) + pow(center.y - point.y, 2) <= pow(bounds.size.width/2, 2)
  }
  
  func coverFrame() -> CGRect {
    let x = (frame.width - innerDiameter!) / 2
    let y = (frame.height - innerDiameter!) / 2
    
    return CGRect(x: x, y: y, width: innerDiameter!, height: innerDiameter!)
  }
  
  func width() -> CGFloat {
    return frame.size.width
  }
  
  func height() -> CGFloat {
    return frame.size.height
  }
  
  func radius() -> CGFloat {
    return width() / 2
  }

  func pieChartize() {
    var startAngle = CGFloat(0.0)
    var startTime = Float(0.0)
    
    for sound in chain!.sounds {
      let layer = CAShapeLayer()
      let endAngle = startAngle + CGFloat((sound.duration / chain!.duration) * 360)
      
      let path = UIBezierPath(
        circleSegmentCenter: CGPoint(x: radius(), y: radius()),
        radius: radius(),
        startAngle: CGFloat(startAngle),
        endAngle: CGFloat(endAngle)
      )
      
      layer.path = path.cgPath
      layer.fillColor = randomColor().cgColor
      layer.strokeColor = UIColor.white.cgColor
      
      piePieces.append((sound, startTime, layer, startAngle, endAngle))
      
      startAngle = min(endAngle, CGFloat(360))
      startTime += sound.duration
    }
    
    for p in piePieces {
      layer.addSublayer(p.piece)
    }
    
    let pieCover = UIView(frame: coverFrame())
    pieCover.backgroundColor = UIColor.white
    pieCover.layer.cornerRadius = innerDiameter! / 2
    addSubview(pieCover)
  }
  
  func startTimeForPiePieceCoveringPoint(point: CGPoint) -> Float {
    let angleInRadians = atan2(CGFloat(point.y - centerY!), CGFloat(point.x - centerX!))
    let angleInDegrees = angleInRadians * CGFloat(180 / M_PI)
    let rotatedAngleToMakeOriginAtTop = angleInDegrees + 90
    let angle = (rotatedAngleToMakeOriginAtTop + 360).truncatingRemainder(dividingBy: 360)
    
    return piePieceForAngle(degreeAngle: angle).startTime
  }
  
  func doubleTap(point: CGPoint) {
    
  }
  
  func piePieceForAngle(degreeAngle: CGFloat) -> (sound: Sound, startTime: Float, piece: CAShapeLayer, startAngle: CGFloat, endAngle: CGFloat) {
    let pieIndex = piePieces.index(where: { item -> Bool in
      return item.startAngle < degreeAngle && item.endAngle > degreeAngle
    })!
    
    return piePieces[pieIndex]
  }
}
