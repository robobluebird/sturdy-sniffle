//
//  InterestingView.swift
//  tel
//
//  Created by robobluebird on 11/11/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit

class InterestingView : UIView {
  var shape: Shape?
  var color: UIColor?
  
  init(frame: CGRect, shape: Shape, color: UIColor? = nil) {
    self.shape = shape
    self.color = color
    
    super.init(frame: frame)
    
    backgroundColor = .clear
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }
    
    context.beginPath()
    
    if shape == Shape.play {
      context.move(to: CGPoint(x: rect.minX, y: rect.minY))
      context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY / 2.0))
      context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
      context.closePath()
    } else if shape == Shape.download {
      context.move(to: CGPoint(x: rect.maxX * 0.3, y: rect.minY))
      context.addLine(to: CGPoint(x: rect.maxX * 0.3, y: rect.maxY * 0.6))
      context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * 0.6))
      context.addLine(to: CGPoint(x: rect.maxX / 2, y: rect.maxY))
      context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.6))
      context.addLine(to: CGPoint(x: rect.maxX * 0.7, y: rect.maxY * 0.6))
      context.addLine(to: CGPoint(x: rect.maxX * 0.7, y: rect.minY))
      context.closePath()
    } else if shape == Shape.upwardPointingArrow {
      context.move(to: CGPoint(x: rect.maxX * 0.3, y: rect.minY))
      context.addLine(to: CGPoint(x: rect.maxX * 0.3, y: rect.maxY * 0.6))
      context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * 0.6))
      context.addLine(to: CGPoint(x: rect.maxX / 2, y: rect.maxY))
      context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.6))
      context.addLine(to: CGPoint(x: rect.maxX * 0.7, y: rect.maxY * 0.6))
      context.addLine(to: CGPoint(x: rect.maxX * 0.7, y: rect.minY))
      context.closePath() 
    } else if shape == Shape.include {
      context.addRect(CGRect(x: rect.minX, y: rect.maxY * 0.8, width: rect.maxX * 0.2, height: rect.maxX * 0.2))
      context.addRect(CGRect(x: rect.maxX * 0.4, y: rect.maxY * 0.8, width: rect.maxX * 0.2, height: rect.maxX * 0.2))
      context.addRect(CGRect(x: rect.maxX * 0.8, y: rect.maxY * 0.8, width: rect.maxX * 0.2, height: rect.maxX * 0.2))
      
      context.move(to: CGPoint(x: rect.maxX * 0.45, y: rect.minY))
      context.addLine(to: CGPoint(x: rect.maxX * 0.45, y: rect.maxY * 0.5))
      context.addLine(to: CGPoint(x: rect.maxX * 0.3, y: rect.maxY * 0.5))
      context.addLine(to: CGPoint(x: rect.maxX / 2, y: rect.maxY * 0.7))
      context.addLine(to: CGPoint(x: rect.maxX * 0.7, y: rect.maxY * 0.5))
      context.addLine(to: CGPoint(x: rect.maxX * 0.55, y: rect.maxY * 0.5))
      context.addLine(to: CGPoint(x: rect.maxX * 0.55, y: rect.minY))
      context.closePath()
      context.rotate(by: 90.0)
    } else if shape == Shape.exclude {
      context.addRect(CGRect(x: rect.minX, y: rect.maxY * 0.8, width: rect.maxX * 0.2, height: rect.maxX * 0.2))
      context.addRect(CGRect(x: rect.maxX * 0.4, y: rect.minY, width: rect.maxX * 0.2, height: rect.maxX * 0.2))
      context.addRect(CGRect(x: rect.maxX * 0.8, y: rect.maxY * 0.8, width: rect.maxX * 0.2, height: rect.maxX * 0.2))
      
      context.move(to: CGPoint(x: rect.maxX * 0.45, y: rect.maxY))
      context.addLine(to: CGPoint(x: rect.maxX * 0.45, y: rect.maxY * 0.5))
      context.addLine(to: CGPoint(x: rect.maxX * 0.3, y: rect.maxY * 0.5))
      context.addLine(to: CGPoint(x: rect.maxX / 2, y: rect.maxY * 0.3))
      context.addLine(to: CGPoint(x: rect.maxX * 0.7, y: rect.maxY * 0.5))
      context.addLine(to: CGPoint(x: rect.maxX * 0.55, y: rect.maxY * 0.5))
      context.addLine(to: CGPoint(x: rect.maxX * 0.55, y: rect.maxY))
      context.closePath()
    } else if shape == Shape.delete {
      context.move(to: CGPoint(x: rect.minX, y: rect.maxY * 0.1))
      context.addLine(to: CGPoint(x: rect.maxX * 0.4, y: rect.maxY * 0.5))
      context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * 0.9))
      context.addLine(to: CGPoint(x: rect.maxX * 0.1, y: rect.maxY))
      context.addLine(to: CGPoint(x: rect.maxX * 0.5, y: rect.maxY * 0.6))
      context.addLine(to: CGPoint(x: rect.maxX * 0.9, y: rect.maxY))
      context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.9))
      context.addLine(to: CGPoint(x: rect.maxX * 0.6, y: rect.maxY * 0.5))
      context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.1))
      context.addLine(to: CGPoint(x: rect.maxX * 0.9, y: rect.minY))
      context.addLine(to: CGPoint(x: rect.maxX * 0.5, y: rect.maxY * 0.4))
      context.addLine(to: CGPoint(x: rect.maxX * 0.1, y: rect.minY))
      context.closePath()
    } else if shape == Shape.ok {
      context.move(to: CGPoint(x: rect.minX, y: rect.maxY * 0.7))
      context.addLine(to: CGPoint(x: rect.maxX * 0.3, y: rect.maxY))
      context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.1))
      context.addLine(to: CGPoint(x: rect.maxX * 0.9, y: rect.minY))
      context.addLine(to: CGPoint(x: rect.maxX * 0.3, y: rect.maxY * 0.8))
      context.addLine(to: CGPoint(x: rect.maxX * 0.1, y: rect.maxY * 0.6))
      context.closePath()
    } else if shape == Shape.email {
      context.addRect(CGRect(x: rect.maxX * 0.1, y: rect.maxY * 0.2, width: 2, height: rect.maxX * 0.8))
      context.addRect(CGRect(x: rect.maxX * 0.1, y: rect.maxY * 0.8, width: rect.maxX * 0.8, height: 2))
      context.addRect(CGRect(x: rect.maxX * 0.9, y: rect.maxY * 0.2, width: 2, height: rect.maxX * 0.8))
      context.addRect(CGRect(x: rect.maxX * 0.1, y: rect.maxY * 0.2, width: rect.maxX * 0.8, height: 2))
    } else {
      return
    }
    
    if color != nil {
      context.setFillColor(color!.cgColor)
    } else {
      context.setFillColor(UIColor.black.cgColor)
    }
    
    context.fillPath()
  }
}
