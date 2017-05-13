//
//  SoundCell.swift
//  tel
//
//  Created by robobluebird on 10/10/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit

class SoundCell: UITableViewCell {
  @IBOutlet var timeLabel: UILabel!
  @IBOutlet var playButton: UIView!
  @IBOutlet var includeOrExcludeButton: UIView!
  @IBOutlet var downloadButton: UIView!
  @IBOutlet var deleteButton: UIView!
  
  @IBOutlet var exteriorProgressBar: UIView!
  @IBOutlet var interiorProgressBar: UIView!
  @IBOutlet var progressBarWidthConstraint: NSLayoutConstraint!
  
  var progressBarWidth: CGFloat?
  var sound: Sound?
  
  var include: UIView?
  var exclude: UIView?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    progressBarWidth = contentView.bounds.width
    progressBarWidthConstraint.constant = 0.0
    
    // make the play
    let triangle = InterestingView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), shape: Shape.play)
    triangle.backgroundColor = UIColor.clear
    playButton.addSubview(triangle)
    playButton.backgroundColor = UIColor.clear
    
    // make the include
    include = InterestingView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), shape: Shape.include, color: .green)
    include!.backgroundColor = UIColor.clear
    includeOrExcludeButton.addSubview(include!)
    includeOrExcludeButton.backgroundColor = UIColor.clear
    
    // make the exclude
    exclude = InterestingView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), shape: Shape.exclude, color: .red)
    exclude!.backgroundColor = UIColor.clear
    includeOrExcludeButton.addSubview(exclude!)
    includeOrExcludeButton.backgroundColor = UIColor.clear
    
    // make the download
    let download = InterestingView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), shape: Shape.download, color: hexStringToUIColor("408000"))
    download.backgroundColor = UIColor.clear
    downloadButton.addSubview(download)
    downloadButton.backgroundColor = UIColor.clear
    
    // make the delete
    let delete = InterestingView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), shape: Shape.delete, color: hexStringToUIColor("D04425"))
    delete.backgroundColor = UIColor.clear
    deleteButton.addSubview(delete)
    deleteButton.backgroundColor = UIColor.clear
    
    toggleIncludeButtonView(included: false)
  }
  
  func configure(_ potentialSound: Sound?) {
    progressBarWidthConstraint.constant = 0
    
    if sound != nil {
      // self.tag = sound!.id
      self.timeLabel.text = sound?.displayTime()
      
      if potentialSound != nil && potentialSound!.id == sound!.id {
        showPlayer()
        
        toggleIncludeButtonView(included: sound!.position > 0)
      } else {
        hidePlayer()
      }
    }
  }
  
  func toggleIncludeButtonView(included: Bool = false) {
    if included {
      include!.isHidden = true
      exclude!.isHidden = false
    } else {
      include!.isHidden = false
      exclude!.isHidden = true
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
  
  func hidePlayer() {
    playButton.isHidden = true
    includeOrExcludeButton.isHidden = true
    downloadButton.isHidden = true
    deleteButton.isHidden = true
  }
  
  func showPlayer() {
    playButton.isHidden = false
    includeOrExcludeButton.isHidden = false
    downloadButton.isHidden = false
    deleteButton.isHidden = false
  }
  
  func setProgressBarProgress(time: Float) {
    if sound != nil && progressBarWidth != nil {
      let prct = time / sound!.duration
      
      print("\(progressBarWidth!) - \(prct) - \(time) - \(sound!.duration) - \(progressBarWidth! / CGFloat(prct))")
      
      progressBarWidthConstraint.constant = progressBarWidth! * CGFloat(prct)
    }
  }
}
