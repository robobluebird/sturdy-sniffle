//
//  ChainCell.swift
//  tel
//
//  Created by robobluebird on 10/10/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit
import AVFoundation

class ChainCell: UITableViewCell {
  var chain: Chain?
  
  @IBOutlet var playButton: UIView!
  @IBOutlet var configureButton: UIView!
  @IBOutlet var recordButton: UIView!
  @IBOutlet var downloadButton: UIView!
  
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  @IBOutlet var playerHeight: NSLayoutConstraint!
  @IBOutlet var progressBar: UIView!
  @IBOutlet var progressIndicator: UIView!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var progressIndicatorLeftSpace: NSLayoutConstraint!
  
  var progressBarTappedCallback: ((Float) -> Void)?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // make it a circle
    recordButton.layer.cornerRadius = 15
    
    // make it a triangle
    let triangle = InterestingView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), shape: Shape.play)
    triangle.backgroundColor = UIColor.clear
    playButton.addSubview(triangle)
    playButton.backgroundColor = UIColor.clear
    
    // make the download
    let download = InterestingView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), shape: Shape.download, color: hexStringToUIColor("408000"))
    download.backgroundColor = UIColor.clear
    downloadButton.addSubview(download)
    downloadButton.backgroundColor = UIColor.clear
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  let PLAYER_HEIGHT: CGFloat = 84.0
  var widthDivisor: Float?
  
  func hidePlayer() {
    playerHeight.constant = 0.0
  }
  
  func showPlayer() {
    playerHeight.constant = PLAYER_HEIGHT
  }
  
  func layoutProgressBar(callback: (() -> Void)?) {
    let totalLength = self.bounds.width
    
    widthDivisor = Float(totalLength) / chain!.duration
    
    var leftOffset = 0.0
    
    for (index, soundWithTime) in chain!.soundsWithTimes.enumerated() {
      let prct = soundWithTime.sound.duration / chain!.duration
      let width = Double(Float(totalLength) * prct)

      let view = UIView(frame: CGRect(x: leftOffset, y: 0.0, width: width, height: 20.0))
      // view.backgroundColor = hexStringToUIColor(soundWithTime.sound.creator.color)
      
      let color = hexStringToUIColor("EBEBEB")
      let leftEdge = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 2.0, height: 20.0))
      let topEdge = UIView(frame: CGRect(x: 0.0, y: 0.0, width: width, height: 2.0))
      let bottomEdge = UIView(frame: CGRect(x: 0.0, y: 18.0, width: width, height: 2.0))
      
      leftEdge.backgroundColor = color
      topEdge.backgroundColor = color
      bottomEdge.backgroundColor = color
      
      view.addSubview(leftEdge)
      view.addSubview(topEdge)
      view.addSubview(bottomEdge)
      
      if index == chain!.soundsWithTimes.count - 1 {
        let rightEdge = UIView(frame: CGRect(x: width - 2.0, y: 0.0, width: 2.0, height: 20.0))
        rightEdge.backgroundColor = color
        view.addSubview(rightEdge)
      }
      
      let tap = ProgressBarSegmentUITapGestureRecognizer(target: self, action: #selector(ChainCell.progressBarTap(gesture:)))
      tap.time = soundWithTime.startTime
      view.addGestureRecognizer(tap)
      
      progressBar.addSubview(view)
      leftOffset += width
    }
    
    if callback != nil {
      callback!()
    }
  }
  
  func configure(_ potentialChain: Chain?, potentialUser: User? = nil) {
    progressIndicatorLeftSpace.constant = 0
    
    if chain != nil {
      // self.tag = chain!.id
      self.titleLabel.text = chain!.text
      
      if potentialChain != nil && potentialChain!.id == chain!.id {
        layoutProgressBar(callback: {
          self.showPlayer()
        })
      } else {
        hidePlayer()
      }
    }
  }
  
  func setPlayButtonToPlay() {
    playButton.backgroundColor = UIColor.clear
  }
  
  func setPlayButtonToStop() {
    playButton.backgroundColor = UIColor.black
  }
  
  func enablePlayerControls() {
    playButton.isUserInteractionEnabled = true
    playButton.alpha = 1.0
  }
  
  func disablePlayerControls() {
    playButton.isUserInteractionEnabled = false
    playButton.alpha = 0.2
  }
  
  func hideConfigureButton() {
    configureButton.isUserInteractionEnabled = false
    configureButton.alpha = 0.0
  }
  
  func setProgressBarProgress(time: Float) {
    self.progressIndicatorLeftSpace.constant = CGFloat(self.widthDivisor! * time)
  }
  
  func progressBarTap(gesture: ProgressBarSegmentUITapGestureRecognizer) {
    if gesture.time != nil && progressBarTappedCallback != nil {
      progressBarTappedCallback!(gesture.time!)
    }
  }
}
