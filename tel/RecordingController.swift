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
  @IBOutlet var outerRecordButton: UIView!
  @IBOutlet var innerRecordButton: UIView!
  @IBOutlet var meterBarsHolder: UIView!
  
  @IBOutlet var outerRecordButtonHeight: NSLayoutConstraint!
  @IBOutlet var outerRecordButtonWidth: NSLayoutConstraint!
  @IBOutlet var innerRecordButtonHeight: NSLayoutConstraint!
  @IBOutlet var innerRecordButtonWidth: NSLayoutConstraint!
  
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
  
  let barHolderHeight: CGFloat = 0.0
  var meterBarWidth: CGFloat = 0.0
  var meterBarHolderWidth: CGFloat = 0.0
  var meterBarLeftOffset: CGFloat = 0.0
  var widthDivisor: CGFloat?
  
  var playheadLeftOffset: CGFloat = 0.0
  let playhead = UIView(frame: CGRect(x: 0.0, y: -10.0, width: 2.0, height: 20.0))
  
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
    
    inactiveColor = innerRecordButton.backgroundColor
    
    // make it a circle
    outerRecordButtonHeight.constant = buttonSize
    outerRecordButtonWidth.constant = buttonSize
    innerRecordButtonHeight.constant = buttonSize * 0.8
    innerRecordButtonWidth.constant = buttonSize * 0.8
    outerRecordButton.layer.cornerRadius = buttonSize / 2
    innerRecordButton.layer.cornerRadius = buttonSize * 0.8 / 2
    
    // meter
    meterBarHolderWidth = UIScreen.main.bounds.width * 0.92
    meterBarWidth = meterBarHolderWidth / 150.0
    
    lpgr = UILongPressGestureRecognizer(target: self, action: #selector(RecordingController.handleLongPress(gestureReconizer:)))
    lpgr!.minimumPressDuration = 0.0
    lpgr!.delaysTouchesBegan = true
    innerRecordButton.addGestureRecognizer(lpgr!)
    
    playhead.backgroundColor = UIColor.black
    
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
    
    do {
      try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
      
      session.requestRecordPermission { result in
        self.enableRecorder()
      }
      
      try session.setActive(true)
    } catch {
      NSLog("\(error)")
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
  
  func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
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
  
  func startRecording() {
    player?.stop()
    timer?.invalidate()
    player = nil
    
    hidePlayhead()
    
    if resetRecorder {
      recordedTime = 0.0
      meterBarLeftOffset = 0.0
      meterBarsHolder.subviews.forEach({ $0.removeFromSuperview() })
      resetRecorder = false
    }
    
    innerRecordButton.backgroundColor = UIColor.red
    recorder!.record()
    
    if recorder!.isRecording {
      timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(RecordingController.updateRecording), userInfo: nil, repeats: true)
    }
  }
  
  func stopRecording() {
    innerRecordButton.backgroundColor = inactiveColor
    recordedTime += recorder!.currentTime
    recorder!.stop()
    timer?.invalidate()
    
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
    
    recordedTime = 0.0
    meterBarLeftOffset = 0.0
    meterBarsHolder.subviews.forEach({ $0.removeFromSuperview() })
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
        NSLog("DUMB: \(exportSession!.error)")
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
      player!.play()
      
      if player!.isPlaying {
        DispatchQueue.main.async {
          self.showPlayhead()
          self.enableGoButton()
          
          self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(RecordingController.updatePlayer), userInfo: nil, repeats: true)
        }
      }
    } catch {
      NSLog("DUMB: \(error)")
    }
  }
  
  func hidePlayhead() {
    DispatchQueue.main.async {
      self.disableClearButton()
      self.playhead.removeFromSuperview()
    }
  }
  
  func showPlayhead() {
    DispatchQueue.main.async {
      self.enableClearButton()
      self.meterBarsHolder.addSubview(self.playhead)
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

  func updatePlayer() {
    if player != nil {
      var frame = playhead.frame
      let prct = player!.currentTime / 15.0
      let total = meterBarHolderWidth * CGFloat(prct)
      frame.origin.x = total
      playhead.frame = frame
    }
  }
  
  func updateRecording() {
    if recordedTime + recorder!.currentTime > recordTime {
      stopRecording()
    }
    
    var barHeight = CGFloat(meterBarHeight())
    
    if barHeight < 1.0 {
      barHeight = 1.0
    } else if barHeight > 50.0 {
      barHeight = 50.0
    }
    
    let meterBar = UIView(frame: CGRect(x: meterBarLeftOffset, y: barHolderHeight - barHeight, width: meterBarWidth, height: barHeight))
    let meterBarDownward = UIView(frame: CGRect(x: meterBarLeftOffset, y: barHolderHeight, width: meterBarWidth, height: barHeight))
    
    meterBar.backgroundColor = UIColor.red
    meterBarDownward.backgroundColor = UIColor.red
    
    meterBarsHolder.addSubview(meterBar)
    meterBarsHolder.addSubview(meterBarDownward)
    
    meterBarLeftOffset += meterBarWidth
  }
  
  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    lpgr!.isEnabled = false
    lpgr!.isEnabled = true
  }
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    player.play()

    if player.isPlaying {
      self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(RecordingController.updatePlayer), userInfo: nil, repeats: true)
    }
  }
  
  func meterBarHeight() -> Float {
    recorder!.updateMeters()
    
    let minDecibels: Float = -120.0
    let decibels = recorder!.averagePower(forChannel: 0)
    
    if decibels < minDecibels {
      return 0.0
    } else if decibels >= 0.0 {
      return 1.0
    } else {
      let minAmp = powf(10, 0.05 * minDecibels)
      let inverseAmpRange = 1.0 / (1.0 - minAmp)
      let amp = powf(10, 0.05 * decibels)
      let adjustedAmp = (amp - minAmp) * inverseAmpRange
      
      return powf(adjustedAmp, 1.0) * 100.0
    }
  }
}
