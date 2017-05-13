//
//  PlayController.swift
//  tel
//
//  Created by robobluebird on 4/26/17.
//  Copyright © 2017 bitewolf. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class PlayController: UIViewController, AVAudioPlayerDelegate, UIGestureRecognizerDelegate {
  @IBOutlet var progressHolder: UIView!
  @IBOutlet var piesHolder: UIView!
  
  @IBOutlet var progressHolderWidth: NSLayoutConstraint!
  @IBOutlet var progressHolderHeight: NSLayoutConstraint!
  @IBOutlet var playButtonWidth: NSLayoutConstraint!
  @IBOutlet var playButtonHeight: NSLayoutConstraint!
  @IBOutlet var piesHolderHeight: NSLayoutConstraint!
  
  var progress = CAShapeLayer()
  var percentDivisor = 0.0
  var lpgr: UILongPressGestureRecognizer?
  var tg: UITapGestureRecognizer?
  var lsg: UISwipeGestureRecognizer?
  var rsg: UISwipeGestureRecognizer?
  var timer: Timer?
  var playingRate = 0.0
  var audio: AVAudioPlayer?
  var currentChain: Chain?
  var soundPoints: [Float] = []
  var pies: [Pie] = []
  var currentPieIndex = 0
  var playing = false
  var record = UIView()
  var playButton = UIView()
  var playButtonGraphic = UIView()
  let progressSize = CGFloat(8.0)
  let screenCenterX = UIScreen.main.bounds.width / 2
  let screenCenterY = UIScreen.main.bounds.height / 2
  let pieSize = UIScreen.main.bounds.width / 2
  var pieTap: UITapGestureRecognizer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let origin = CGPoint(x: UIScreen.main.bounds.width / 2 - (pieSize * 0.8) / 2, y: UIScreen.main.bounds.height / 2 - (pieSize * 0.8) / 2)
    let size = CGSize(width: pieSize * 0.8, height: pieSize * 0.8)
    playButton = Circle(frame: CGRect(origin: origin, size: size))
    
    // make the play button
    let triangle = InterestingView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), shape: Shape.play)
    triangle.backgroundColor = UIColor.clear
    playButtonGraphic = UIView(frame: CGRect(origin: CGPoint(x: pieSize / 2 - 30, y: pieSize / 2 - 30), size: CGSize(width: 30, height: 30)))
    playButtonGraphic.addSubview(triangle)
    playButtonGraphic.backgroundColor = UIColor.clear
    playButton.addSubview(playButtonGraphic)
    view.addSubview(playButton)
    
    // tap for pie
    pieTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handlePieTap(gestureRecognizer:)))
    
    // tap for play button
    tg = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleTap(gestureRecognizer:)))
    playButton.addGestureRecognizer(tg!)
    
    // progress
    progress = progressPie()
    
    // audio
    configureAudioSession()
    
    // nav
    setNavigationItems()
    
    // actions
    setActions()
    disableControls()
    
    // pie holder
    piesHolderHeight.constant = pieSize
    lsg = UISwipeGestureRecognizer(target: self, action: #selector(PlayController.handleSwipe(gestureRecognizer:)))
    rsg = UISwipeGestureRecognizer(target: self, action: #selector(PlayController.handleSwipe(gestureRecognizer:)))
    lsg!.direction = .left
    rsg!.direction = .right
    piesHolder.addGestureRecognizer(lsg!)
    piesHolder.addGestureRecognizer(rsg!)
    
    // get chains
    fetchChains(nil, completedCallback: { chains, amount in
      if chains.count > 0 {
        self.createPies(chains: chains)
      } else {
        showAlert(context: self, message: "there's nothing to show :(")
      }
    }, failedCallback: {
      showAlert(context: self, message: "delete your account >:(")
    });
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func setActions() {
    let actionSize = pieSize / 4
    let x = (UIScreen.main.bounds.width / 2) - (actionSize / 2)
    let y = UIScreen.main.bounds.height * 0.75
    
    // make the record button
    record = UIView(frame: CGRect(x: x, y: y, width: actionSize, height: actionSize))
    record.layer.cornerRadius = actionSize / 2
    record.backgroundColor = .red
    
    // tap for record button
    let recordTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleRecordTap(gestureRecognizer:)))
    
    record.addGestureRecognizer(recordTap)
    
    view.addSubview(record)
  }
  
  func setNavigationItems() {
    let rect = CGRect(x: 0, y: 0, width: pieSize / 6, height: pieSize / 6)
    let button = UIButton(frame: rect)
    button.backgroundColor = UIColor.red
    button.layer.cornerRadius = pieSize / 12
    button.addTarget(self, action: #selector(PlayController.toNewRecording(sender:)), for: .touchUpInside)
    
    let recordIt = UIBarButtonItem(customView: button)
    
    self.navigationItem.rightBarButtonItem = recordIt
  }
  
  func toNewRecording(sender: AnyObject) {
    let recorder: RecordingController = self.storyboard?.instantiateViewController(withIdentifier: "RecordingController") as! RecordingController
    
    self.navigationController!.present(recorder, animated: true, completion: {})
  }
  
  func createPies(chains: [Chain]) {
    var offset = (x: piesHolder.center.x - (pieSize / 2), y: CGFloat(0.0))
    
    for c in chains {
      let p = Pie(chain: c, origin: offset, size: pieSize)
      
      pies.append(p)
      
      let newX = offset.x + (piesHolder.bounds.width / 2)
      let newY = offset.y
      
      offset = (x: newX, y: newY)
    }
    
    renderPies()
    loadChain()
  }
  
  func renderPies() {
    for p in pies {
      piesHolder.addSubview(p)
    }
    
    view.bringSubview(toFront: playButton)
  }
  
  func progressPie() -> CAShapeLayer {
    let radians = (-90 / 180) * CGFloat(M_PI)
    let newX = screenCenterX + (pieSize / 2 - progressSize) * cos(radians)
    let newY = screenCenterY + (pieSize / 2 - progressSize) * sin(radians)

    let layer = CAShapeLayer()
    
    layer.path = UIBezierPath(arcCenter: CGPoint(x: newX, y: newY), radius: progressSize / 2, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true).cgPath
    
    layer.strokeColor = UIColor.black.cgColor
    layer.fillColor = UIColor.clear.cgColor
    layer.lineWidth = 1.0
    
    let subLayer = CAShapeLayer()
    
    subLayer.path = UIBezierPath(arcCenter: CGPoint(x: newX, y: newY), radius: 3, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true).cgPath
    
    subLayer.strokeColor = UIColor.white.cgColor
    subLayer.fillColor = UIColor.clear.cgColor
    subLayer.lineWidth = 1.0
    
    layer.addSublayer(subLayer)
    
    view.layer.addSublayer(layer)
    
    return layer
  }
  
  func updateProgress(angle: CGFloat) {
    let radians = (angle - 90) * (CGFloat(M_PI) / 180)
    let newX = screenCenterX + (pieSize / 2 - progressSize) * cos(radians)
    let newY = screenCenterY + (pieSize / 2 - progressSize) * sin(radians)
    
    progress.path = UIBezierPath(arcCenter: CGPoint(x: newX, y: newY), radius: progressSize / 2, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true).cgPath
    
    (progress.sublayers!.first as! CAShapeLayer).path = UIBezierPath(arcCenter: CGPoint(x: newX, y: newY), radius: 3, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true).cgPath
  }
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    setPlayButtonState(to: .stopped)
    timer?.invalidate()
  }
  
  func setPlayButtonState(to state: PlayButtonState) {
    if state == .playing {
      playButtonGraphic.backgroundColor = UIColor.black
    } else {
      playButtonGraphic.backgroundColor = UIColor.clear
    }
  }
  
  func configureAudioSession() {
    let session = AVAudioSession.sharedInstance()
    
    do {
      try session.setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
      try session.setActive(true)
      UIApplication.shared.beginReceivingRemoteControlEvents()
    } catch {
      NSLog("\(error)")
    }
  }
  
  func unloadChain() {
    disableControls()
    pies[currentPieIndex].removeGestureRecognizer(pieTap!)
  }
  
  func loadChain() {
    if pies.count - 1 < currentPieIndex {
      return
    }
    
    if let chain = pies[currentPieIndex].chain {
      initAudio(chain.url, callback: {
        self.pies[self.currentPieIndex].addGestureRecognizer(self.pieTap!)
        self.setPlayProgress()
        self.enableControls()
      })
    }
  }
  
  func initAudio(_ url: String, callback: @escaping () -> Void) {
    Alamofire.request(url).responseData(completionHandler: { dataResponse in
      if dataResponse.data != nil {
        do {
          try self.audio = AVAudioPlayer(data: dataResponse.data!)
          self.audio!.delegate = self
          self.audio!.prepareToPlay()
          self.percentDivisor = 360 / self.audio!.duration
          callback()
        } catch {
          NSLog("oh deary me. \(self.audio) failed to play in for url \(url)")
        }
      }
    })
  }
  
  func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state == .began {
      startPlaying()
    } else if gestureRecognizer.state == .ended {
      stopPlaying()
    }
  }
  
  func handleTap(gestureRecognizer: UITapGestureRecognizer) {
    playing ? stopPlaying() : startPlaying()
  }
  
  func handlePieTap(gestureRecognizer: UITapGestureRecognizer) {
    let point = gestureRecognizer.location(in: pies[currentPieIndex])
    let time = pies[currentPieIndex].startTimeForPiePieceCoveringPoint(point: point)
    
    audio!.currentTime = TimeInterval(time)
    
    if !audio!.isPlaying {
      setPlayProgress()
    }
  }
  
  func handleRecordTap(gestureRecognizer: UITapGestureRecognizer) {
    let recorder: RecordingController = self.storyboard?.instantiateViewController(withIdentifier: "RecordingController") as! RecordingController
    
    recorder.chain = pies[currentPieIndex].chain
    recorder.modalPresentationStyle = .popover
    
    self.navigationController!.present(recorder, animated: true, completion: {})
  }
  
  func handleSwipe(gestureRecognizer: UISwipeGestureRecognizer) {
    var newX = CGFloat(0.0)
    var pieChange = 0
    
    if gestureRecognizer.direction == .left {
      if currentPieIndex < pies.count - 1 {
        newX = newX - (piesHolder.bounds.width / 2)
        pieChange += 1
      }
    } else if gestureRecognizer.direction == .right {
      if currentPieIndex > 0 {
        newX = newX + (piesHolder.bounds.width / 2)
        pieChange -= 1
      }
    }
    
    if newX != 0.0 {
      self.unloadChain()
      currentPieIndex += pieChange
      
      UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
        for view in self.piesHolder.subviews {
          view.frame.origin.x = view.frame.origin.x + newX
        }
      }, completion: { success in
        self.loadChain()
      })
    } else {
      let bounceValue = gestureRecognizer.direction == .left ? -(pieSize / 4) : pieSize / 4
      
      self.disableControls()
      
      UIView.animate(withDuration: 0.2, delay: 0.0, options: .autoreverse, animations: {
        for view in self.piesHolder.subviews {
          view.frame.origin.x = view.frame.origin.x + CGFloat(bounceValue)
        }
      }, completion: { completed in
        self.enableControls()
      })
    }
  }
  
  func enableControls() {
    progress.strokeColor = UIColor.black.cgColor
    playButton.backgroundColor = .white
    playButton.layer.opacity = 1.0
    playButton.isUserInteractionEnabled = true
    record.isUserInteractionEnabled = true
    record.layer.opacity = 1.0
  }
  
  func disableControls() {
    progress.strokeColor = UIColor.clear.cgColor
    playButton.backgroundColor = .clear
    playButton.layer.opacity = 0.5
    playButton.isUserInteractionEnabled = false
    record.isUserInteractionEnabled = false
    record.layer.opacity = 0.5
  }
  
  func loadSoundPoints() {
    for (_, soundWithTime) in currentChain!.soundsWithTimes.enumerated() {
      soundPoints.append(soundWithTime.startTime!)
    }
  }
  
  func startPlaying() {
    if audio != nil {
      playing = true
      setPlayButtonState(to: .playing)
      audio!.play()
      timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(PlayController.setPlayProgress), userInfo: nil, repeats: true)
    }
  }
  
  func stopPlaying() {
    if audio != nil && timer != nil {
      playing = false
      setPlayButtonState(to: .paused)
      timer!.invalidate()
      audio!.pause()
    }
  }
  
  func setPlayProgress() {
    if audio != nil {
      let angle = CGFloat(percentDivisor * audio!.currentTime)
      updateProgress(angle: angle)
    }
  }
}
