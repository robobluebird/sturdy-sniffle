//
//  Pie.swift
//  tel
//
//  Created by robobluebird on 4/29/17.
//  Copyright © 2017 bitewolf. All rights reserved.
//

import UIKit

class Pie: CircleView {
  var circle = Circle()
  var progressLayer = CAShapeLayer()
  var outerDiameter = CGFloat(0.0)
  var innerDiameter = CGFloat(0.0)
  var piePieces = [(sound: Sound?, startTime: Float?, piece: CAShapeLayer, startAngle: CGFloat, endAngle: CGFloat)]()
  var centerX, centerY: CGFloat?
  var enabled = true
  
  init(circle: Circle, origin: (x: CGFloat, y: CGFloat), size: CGFloat) {
    let frame = CGRect(x: origin.x, y: origin.y, width: size, height: size)
    
    super.init(frame: frame)
    
    self.circle = circle
    
    pieChartize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
    
    return pow(center.x-point.x, 2) + pow(center.y - point.y, 2) <= pow(bounds.size.width/2, 2)
  }
  
  func coverFrame(_ override: CGFloat? = nil) -> CGRect {
    var usableValue = innerDiameter
    
    if override != nil {
      usableValue = override!
    }
    
    let x = (bounds.width - usableValue) / 2
    let y = (bounds.height - usableValue) / 2
    
    return CGRect(x: x, y: y, width: usableValue, height: usableValue)
  }
  
  func width() -> CGFloat {
    return bounds.size.width
  }
  
  func height() -> CGFloat {
    return bounds.size.height
  }
  
  func radius() -> CGFloat {
    return width() / 2
  }

  func pieChartize() {
    piePieces.removeAll()
    
    for subview in subviews {
      subview.removeFromSuperview()
    }
    
    layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    
    centerX = frame.size.width / 2.0
    centerY = frame.size.height / 2.0
    outerDiameter = frame.size.width
    innerDiameter = frame.size.width * 0.75
    
    var startAngle = CGFloat(0.0)
    var startTime = Float(0.0)
    
    if circle.url == nil || circle.url == "" || circle.duration <= 0 {
      self.layer.opacity = 0.5
      
      let layer = CAShapeLayer()
      let endAngle = CGFloat(360)
      
      let path = UIBezierPath(
        circleSegmentCenter: CGPoint(x: radius(), y: radius()),
        radius: radius(),
        startAngle: CGFloat(startAngle),
        endAngle: endAngle
      )
      
      layer.path = path.cgPath
      layer.fillColor = UIColor.blue.cgColor
      layer.strokeColor = UIColor.white.cgColor
      
      piePieces.append((nil, nil, layer, startAngle, endAngle))
    } else {
      for sound in circle.sounds {
        let layer = CAShapeLayer()
        let endAngle = startAngle + CGFloat((sound.duration / circle.duration) * 360)
        
        let path = UIBezierPath(
          circleSegmentCenter: CGPoint(x: radius(), y: radius()),
          radius: radius(),
          startAngle: CGFloat(startAngle),
          endAngle: CGFloat(endAngle)
        )
        
        layer.path = path.cgPath
        layer.fillColor = (hexStringToUIColor(sound.color) ?? randomColor()).cgColor
        layer.strokeColor = UIColor.white.cgColor
        
        piePieces.append((sound, startTime, layer, startAngle, endAngle))
        
        startAngle = min(endAngle, CGFloat(360))
        startTime += sound.duration
      }
    }
    
    for p in piePieces {
      layer.addSublayer(p.piece)
    }
    
    // draw pie cover
    let coverLayer = CAShapeLayer()
    
    let path = UIBezierPath(
      circleSegmentCenter: CGPoint(x: radius(), y: radius()),
      radius: radius() * 0.75,
      startAngle: CGFloat(0),
      endAngle: CGFloat(360)
    )
    
    coverLayer.path = path.cgPath
    coverLayer.fillColor = UIColor.white.cgColor
    coverLayer.strokeColor = UIColor.white.cgColor
    
    layer.addSublayer(coverLayer)
  }
  
  func scale(_ scale: CGFloat) {
    for case let sublayer as CAShapeLayer in layer.sublayers! {
      sublayer.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
    }
    
    centerX = frame.size.width / 2.0
    centerY = frame.size.height / 2.0
    outerDiameter = frame.size.width
    innerDiameter = frame.size.width * 0.75
  }
  
  func soundOfPiePieceCoveringPoint(point: CGPoint) -> Sound {
    let angle = angleForPoint(point: point)
    
    return piePieceForAngle(degreeAngle: angle).sound!
  }
  
  func startTimeForPiePieceCoveringPoint(point: CGPoint) -> Float {
    let angle = angleForPoint(point: point)
    
    return piePieceForAngle(degreeAngle: angle).startTime!
  }
  
  func angleForPoint(point: CGPoint) -> CGFloat {
    let angleInRadians = atan2(CGFloat(point.y - centerY!), CGFloat(point.x - centerX!))
    let angleInDegrees = angleInRadians * (180 / .pi)
    let rotatedAngleToMakeOriginAtTop = angleInDegrees + 90
    
    return (rotatedAngleToMakeOriginAtTop + 360).truncatingRemainder(dividingBy: 360)
  }
  
  func piePieceForAngle(degreeAngle: CGFloat) -> (sound: Sound?, startTime: Float?, piece: CAShapeLayer, startAngle: CGFloat, endAngle: CGFloat) {
    let pieIndex = piePieces.index(where: { item -> Bool in
      return item.startAngle < degreeAngle && item.endAngle > degreeAngle
    })!
    
    return piePieces[pieIndex]
  }
  
  func enable() {
    piePieces.forEach({ piece in piece.piece.opacity = 1.0 })
    isUserInteractionEnabled = true
    enabled = true
  }
  
  func disable() {
    if circle.url == nil || circle.url == "" {
    }
    
    piePieces.forEach({ piece in piece.piece.opacity = 0.5 })
    isUserInteractionEnabled = false
    enabled = false
  }
  
  func maybeDisable() {
    if circle.url == nil || circle.url == "" {
      piePieces.forEach({ piece in piece.piece.opacity = 0.5 })
      isUserInteractionEnabled = false
      enabled = false
    }
  }
}
