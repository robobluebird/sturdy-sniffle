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
  var piePieces = [(sound: Sound?, startTime: Float?, piece: CAShapeLayer, startAngle: CGFloat, endAngle: CGFloat)]()
  var centerX, centerY: CGFloat?
  var enabled = true
  var processingLabel = UILabel()
  
  init(chain: Chain, origin: (x: CGFloat, y: CGFloat), size: CGFloat) {
    let frame = CGRect(x: origin.x, y: origin.y, width: size, height: size)
    
    super.init(frame: frame)
    
    centerX = bounds.width / 2.0
    centerY = bounds.height / 2.0
    outerDiameter = size
    innerDiameter = size * 0.8
    
    backgroundColor = UIColor.white
    layer.cornerRadius = frame.width / 2
    
    self.chain = chain
    
    processingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: size, height: size))
    processingLabel.font = processingLabel.font.withSize(50).italic()
    processingLabel.adjustsFontSizeToFitWidth = true
    processingLabel.numberOfLines = 0
    processingLabel.textAlignment = .center
    processingLabel.text = "please hold..."
    processingLabel.isHidden = true
    
    addSubview(processingLabel)
    
    pieChartize()
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
    
    if chain == nil || chain!.url == nil || chain!.url == "" || chain!.duration <= 0 {
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
    
    let pieCover = UIView(frame: coverFrame())
    pieCover.backgroundColor = UIColor.white
    pieCover.layer.cornerRadius = innerDiameter! / 2
    addSubview(pieCover)
    bringSubview(toFront: processingLabel)
  }
  
  func startTimeForPiePieceCoveringPoint(point: CGPoint) -> Float {
    let angleInRadians = atan2(CGFloat(point.y - centerY!), CGFloat(point.x - centerX!))
    let angleInDegrees = angleInRadians * CGFloat(180 / M_PI)
    let rotatedAngleToMakeOriginAtTop = angleInDegrees + 90
    let angle = (rotatedAngleToMakeOriginAtTop + 360).truncatingRemainder(dividingBy: 360)
    
    return piePieceForAngle(degreeAngle: angle).startTime!
  }
  
  func piePieceForAngle(degreeAngle: CGFloat) -> (sound: Sound?, startTime: Float?, piece: CAShapeLayer, startAngle: CGFloat, endAngle: CGFloat) {
    let pieIndex = piePieces.index(where: { item -> Bool in
      return item.startAngle < degreeAngle && item.endAngle > degreeAngle
    })!
    
    return piePieces[pieIndex]
  }
  
  func enable() {
    processingLabel.isHidden = true
    piePieces.forEach({ piece in piece.piece.opacity = 1.0 })
    isUserInteractionEnabled = true
    enabled = true
  }
  
  func disable() {
    if chain != nil && (chain!.url == nil || chain!.url == "") {
      bringSubview(toFront: processingLabel)
      processingLabel.isHidden = false
    }
    
    piePieces.forEach({ piece in piece.piece.opacity = 0.5 })
    isUserInteractionEnabled = false
    enabled = false
  }
}
