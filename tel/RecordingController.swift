//
//  RecordingController.swift
//  tel
//
//  Created by robobluebird on 10/18/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate {
  let totalWidth = UIScreen.main.bounds.width
  let totalHeight = UIScreen.main.bounds.height
  let screenCenterX = UIScreen.main.bounds.width / 2
  let screenCenterY = UIScreen.main.bounds.height / 2
  let pieSize = UIScreen.main.bounds.width / 2
  
  var outerRecordButton = Circle()
  var outerRecordCover = Circle()
  var innerRecordButton = Circle()
  var coverLayer = CAShapeLayer()
  var dotsHolder = Circle()
  var dotSize = CGFloat(0)
  
  var recorder: AVAudioRecorder?
  var player: AVAudioPlayer?
  var timer: Timer?
  var chain: Chain?
  var recording = false
  var someCounter = 30
  var lpgr: UILongPressGestureRecognizer?
  var inactiveColor: UIColor?
  var creationCallback: ((Data) -> Void)?
  var additionCallback: ((Data, Chain) -> Void)?

  var percentDivisor = 0.0
  
  var resetRecorder = false
  let recordTime = TimeInterval(15.0)
  var recordedTime = 0.0
  
  let buttonSize = UIScreen.main.bounds.width / 2
  let actionSize = UIScreen.main.bounds.width / 4
  
  var goButton = UIView()
  var cancelButton = UIView()
  var clearButton = UIView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // dotSize
    dotSize = pieSize / 20
    
    // percentDivisor
    percentDivisor = 360 / recordTime
    
    // make it a circle
    let origin = CGPoint(x: screenCenterX - pieSize / 2, y: screenCenterY - pieSize / 2)
    let size = CGSize(width: pieSize, height: pieSize)
    let smallerOrigin = CGPoint(x: screenCenterX - (pieSize * 0.75) / 2, y: screenCenterY - (pieSize * 0.75) / 2)
    let smallerSize = CGSize(width: pieSize * 0.75, height: pieSize * 0.75)
    
    outerRecordButton = Circle(frame: CGRect(origin: origin, size: size))
    outerRecordButton.backgroundColor = .red
    
    outerRecordCover = Circle(frame: CGRect(origin: origin, size: size))
    outerRecordCover.backgroundColor = .clear
    
    dotsHolder = Circle(frame: CGRect(origin: origin, size: size))
    dotsHolder.backgroundColor = .clear
  
    for index in 0...19 {
      let radians = (CGFloat(18 * index) / 180) * .pi
      let x = (pieSize / 2) + (pieSize / 2 * 0.95 - dotSize) * cos(radians) - (dotSize / 2)
      let y = (pieSize / 2) + (pieSize / 2 * 0.95 - dotSize) * sin(radians) - (dotSize / 2)
      let origin = CGPoint(x: x, y: y)
      let size = CGSize(width: dotSize, height: dotSize)
      let circle = Circle(frame: CGRect(origin: origin, size: size))
      circle.backgroundColor = .black
      dotsHolder.addSubview(circle)
    }
    
    coverLayer.fillColor = UIColor.red.cgColor
    coverLayer.strokeColor = UIColor.white.cgColor
    coverLayer.isHidden = true
    dotsHolder.isHidden = true
    outerRecordCover.layer.addSublayer(coverLayer)
    
    innerRecordButton = Circle(frame: CGRect(origin: smallerOrigin, size: smallerSize))
    innerRecordButton.backgroundColor = .white
    inactiveColor = .white
    
    lpgr = UILongPressGestureRecognizer(target: self, action: #selector(RecordingController.handleRecordButtonLongPress(gestureReconizer:)))
    lpgr!.minimumPressDuration = 0.0
    lpgr!.delaysTouchesBegan = true
    innerRecordButton.addGestureRecognizer(lpgr!)
    
    view.addSubview(outerRecordButton)
    view.addSubview(dotsHolder)
    view.addSubview(outerRecordCover)
    view.addSubview(innerRecordButton)
    
    // other setup
    setActions()
    disableGoButton()
    disableClearButton()
    configureAudioSession()
  }
  
  func setActions() {
    let x = UIScreen.main.bounds.width / 2 - actionSize * 1.5
    let y = UIScreen.main.bounds.height * 0.75
    
    // go button
    goButton = UIView(frame: CGRect(x: x, y: y, width: actionSize, height: actionSize))
    let go = InterestingView(frame: CGRect(x: 0, y: 0, width: actionSize, height: actionSize), shape: Shape.ok, color: UIColor.green)
    go.backgroundColor = UIColor.clear
    goButton.addSubview(go)
    let goAction = UITapGestureRecognizer(target: self, action: #selector(RecordingController.goButtonTapped(gesture:)))
    goButton.addGestureRecognizer(goAction)
    
    // cancel button
    cancelButton = UIView(frame: CGRect(x: x * 5, y: y, width: actionSize, height: actionSize))
    let cancel = InterestingView(frame: CGRect(x: 0, y: 0, width: actionSize, height: actionSize), shape: Shape.delete)
    cancel.backgroundColor = UIColor.clear
    cancelButton.addSubview(cancel)
    let cancelAction = UITapGestureRecognizer(target: self, action: #selector(RecordingController.cancelButtonTapped(gesture:)))
    cancelButton.addGestureRecognizer(cancelAction)
    
    // clear button
    clearButton = UIView(frame: CGRect(x: UIScreen.main.bounds.width / 2 - (actionSize / 4 / 2), y: (y * 0.25) - (actionSize / 4), width: actionSize / 4, height: actionSize / 4))
    let clear = InterestingView(frame: CGRect(x: 0, y: 0, width: actionSize / 4, height: actionSize / 4), shape: Shape.delete, color: UIColor.red)
    clear.backgroundColor = UIColor.clear
    clearButton.backgroundColor = UIColor.clear
    clearButton.addSubview(clear)
    
    let clearAction = UITapGestureRecognizer(target: self, action: #selector(RecordingController.clearButtonTapped(gesture:)))
    clearButton.addGestureRecognizer(clearAction)
    
    view.addSubview(goButton)
    view.addSubview(cancelButton)
    view.addSubview(clearButton)
  }
  
  func configureAudioSession() {
    let session = AVAudioSession.sharedInstance()
    
    session.requestRecordPermission { result in
      do {
        try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        try session.setActive(true)
        self.enableRecorder()
      } catch {
        NSLog("\(error)")
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    do {
      let session = AVAudioSession.sharedInstance()
      
      recorder?.stop()
      recorder = nil
      player?.stop()
      timer?.invalidate()
      player = nil
      
      try FileManager.default.removeItem(at: currentPath()!)
      try FileManager.default.removeItem(at: exportPath()!)
      
      try session.setActive(false);
    } catch {
      NSLog("\(error)")
    }
  }

  // MARK: buttons
  
  func handleRecordButtonLongPress(gestureReconizer: UILongPressGestureRecognizer) {
    if gestureReconizer.state == .began {
      startRecording()
    } else if gestureReconizer.state == .ended {
      stopRecording()
    }
  }
  
  // MARK: useful stuff
  
  func colorForTime(time: Int) -> UIColor {
    switch someCounter {
    case 30...23:
      return UIColor.green
    case 22...15:
      return UIColor.yellow
    case 14...7:
      return UIColor.orange
    case 6...0:
      return UIColor.red
    default:
      return UIColor.black
    }
  }
  
  func recordingPath() -> URL? {
    let fm = FileManager.default
    let dirs = fm.urls(for: .documentDirectory, in: .userDomainMask)
    let url = dirs[0]
    
    return url.appendingPathComponent("recording.m4a")
  }
  
  func exportPath() -> URL? {
    let fm = FileManager.default
    let dirs = fm.urls(for: .documentDirectory, in: .userDomainMask)
    let url = dirs[0]
    
    return url.appendingPathComponent("exported.m4a")
  }
  
  func currentPath() -> URL? {
    let fm = FileManager.default
    let dirs = fm.urls(for: .documentDirectory, in: .userDomainMask)
    let url = dirs[0]
    
    return url.appendingPathComponent("current.m4a")
  }
  
  func recordingOptions() -> [String: AnyObject] {
    return [
      AVSampleRateKey : NSNumber(value: Float(44100.0)),
      AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
      AVNumberOfChannelsKey : NSNumber(value: 1),
      AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.low.rawValue))
    ]
  }
  
  func enableRecorder() {
    let url = recordingPath()
    
    do {
      self.recorder = try AVAudioRecorder(url: url! as URL, settings: self.recordingOptions())
      self.recorder!.delegate = self
      self.recorder!.prepareToRecord()
      self.recorder!.isMeteringEnabled = true
    } catch {
      NSLog("\(error)")
    }
  }
  
  func drawCover(angle: CGFloat) {
    let startAngle = CGFloat(0)
    
    let path = UIBezierPath(
      circleSegmentCenter: CGPoint(x: pieSize / 2, y: pieSize / 2),
      radius: pieSize / 2,
      startAngle: startAngle,
      endAngle: CGFloat(angle)
    )
    
    coverLayer.path = path.cgPath
  }
  
  func startRecording() {
    player?.stop()
    timer?.invalidate()
    player = nil
    
    if resetRecorder {
      recordedTime = 0.0
      outerRecordButton.subviews.forEach({ $0.removeFromSuperview() })
      setPlayProgress(zero: true)
      resetRecorder = false
    }
    
    setPlayProgress(zero: true)
    coverLayer.isHidden = false
    dotsHolder.isHidden = false
    outerRecordButton.isHidden = true
    innerRecordButton.backgroundColor = UIColor.red
    recorder!.record()
    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(RecordingController.updateRecording), userInfo: nil, repeats: true)
  }
  
  func stopRecording() {
    innerRecordButton.backgroundColor = inactiveColor
    recordedTime += recorder!.currentTime
    recorder!.stop()
    timer!.invalidate()
    
    do {
      if FileManager.default.fileExists(atPath: currentPath()!.relativePath) {
        append()
      } else {
        try FileManager.default.copyItem(at: recordingPath()!, to: currentPath()!)
        let data = try Data(contentsOf: self.recordingPath()!)
        self.loadPlayer(data: data)
      }
    } catch {
      NSLog("DUMB: \(error)")
    }
    
    if recordedTime > recordTime {
      resetRecorder = true
    }
  }
  
  func clearButtonTapped(gesture: UITapGestureRecognizer) {
    player?.stop()
    timer?.invalidate()
    disableGoButton()
    disableClearButton()
    coverLayer.isHidden = true
    dotsHolder.isHidden = true
    outerRecordButton.isHidden = false
    
    recordedTime = 0.0
    outerRecordButton.subviews.forEach({ $0.removeFromSuperview() })
    drawCover(angle: 0)
    resetRecorder = false
    
    do {
      try FileManager.default.removeItem(at: currentPath()!)
      try FileManager.default.removeItem(at: exportPath()!)
    } catch {
      NSLog("\(error)")
    }
  }
  
  func cancelButtonTapped(gesture: UITapGestureRecognizer) {
    clearButtonTapped(gesture: gesture)
    self.dismiss(animated: true, completion: {})
  }
  
  func append() {
    do {
      let composition = AVMutableComposition()
      let appenderTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
      
      let newAsset = AVURLAsset(url: recordingPath()!)
      let currentAsset = AVURLAsset(url: currentPath()!)
      
      let newAssetTrack = newAsset.tracks(withMediaType: AVMediaTypeAudio).first!
      let currentAssetTrack = currentAsset.tracks(withMediaType: AVMediaTypeAudio).first!
      
      let newTimeRange = CMTimeRange(start: kCMTimeZero, duration: newAsset.duration)
      let currentTimeRange = CMTimeRange(start: kCMTimeZero, duration: currentAsset.duration)
      
      try appenderTrack.insertTimeRange(currentTimeRange, of: currentAssetTrack, at: kCMTimeZero)
      try appenderTrack.insertTimeRange(newTimeRange, of: newAssetTrack, at: currentAsset.duration)
      
      let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
      
      exportSession!.outputURL = exportPath()!
      exportSession!.outputFileType = AVFileTypeAppleM4A
      exportSession!.exportAsynchronously(completionHandler: {
        self.doSomeThings()
      })
    } catch {
      NSLog("DUMB: \(error)")
    }
  }
  
  func doSomeThings() {
    do {
      try FileManager.default.removeItem(at: currentPath()!)
      try FileManager.default.copyItem(at: exportPath()!, to: currentPath()!)
      try FileManager.default.removeItem(at: exportPath()!)
      let data = try Data(contentsOf: currentPath()!)
      self.loadPlayer(data: data)
    } catch {
      NSLog("DUMB: \(error)")
    }
  }
  
  func loadPlayer(data: Data) {
    do {
      try player = AVAudioPlayer(data: data)
      
      player!.delegate = self
      player!.prepareToPlay()
      player!.numberOfLoops = -1
      player!.play()
      
      DispatchQueue.main.async {
        self.enableGoButton()
        self.enableClearButton()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(RecordingController.setPlayProgress), userInfo: nil, repeats: true)
      }
    } catch {
      NSLog("DUMB: \(error)")
    }
  }
  
  func enableGoButton() {
    goButton.isUserInteractionEnabled = true
    goButton.alpha = 1.0
  }
  
  func disableGoButton() {
    goButton.isUserInteractionEnabled = false
    goButton.alpha = 0.2
  }
  
  func enableClearButton() {
    clearButton.isUserInteractionEnabled = true
    clearButton.isHidden = false
  }
  
  func disableClearButton() {
    clearButton.isUserInteractionEnabled = false
    clearButton.isHidden = true
  }
  
  func goButtonTapped(gesture: UITapGestureRecognizer) {
    if player != nil {
      if let data = self.player!.data {
        self.dismiss(animated: true, completion: {
          if self.chain != nil && self.additionCallback != nil {
            self.additionCallback!(data, self.chain!)
          } else if self.creationCallback != nil {
            self.creationCallback!(data)
          }
        })
      } else {
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  func setPlayProgress(zero: Bool = false) {
    var time: Double? = nil
    
    if zero {
      time = 0.0
    } else if player != nil {
      time = player!.currentTime
    }
    
    if time != nil {
      let angle = CGFloat(percentDivisor * time!)
      outerRecordCover.rotateTo(degreeAngle: angle)
      dotsHolder.rotateTo(degreeAngle: angle)
    }
  }
  
  func adjustAudioProgress(by time: Double) {
    var newTime = player!.currentTime + time
    
    if newTime < 0 {
      newTime = player!.duration + newTime
    }
    
    player!.currentTime = newTime
  }
  
  func updateRecording() {
    if recordedTime + recorder!.currentTime > recordTime {
      stopRecording()
    }
    
    let degreeAngle = CGFloat(percentDivisor * (recordedTime + recorder!.currentTime))
    
    drawCover(angle: degreeAngle)
  }
  
  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    lpgr!.isEnabled = false
    lpgr!.isEnabled = true
  }
}
