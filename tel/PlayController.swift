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

class PlayController: UIViewController, AVAudioPlayerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {
  @IBOutlet var piesHolder: UIView!
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
  var soundPoints: [Float] = []
  var pies: [Pie] = []
  var currentPieIndex = 0
  var playing = false
  var record = UIView()
  var playButton = UIView()
  var playButtonGraphic = UIView()
  var loadingScreen = UIView()
  var backdrop = UIView()
  var reloadButton = UIView()
  var randomizeButton = UIView()
  var downloadButton = UIView()
  var linkButton = UIView()
  var nothingHereLabel = UILabel()
  var workingLabel = UILabel()
  var textField = UITextField()
  let progressSize = CGFloat(8.0)
  let totalWidth = UIScreen.main.bounds.width
  let totalHeight = UIScreen.main.bounds.height
  let screenCenterX = UIScreen.main.bounds.width / 2
  let screenCenterY = UIScreen.main.bounds.height / 2
  let pieSize = UIScreen.main.bounds.width / 2
  var audioCache = [String: Data]()
  var pieTap: UITapGestureRecognizer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let coveringSize = pieSize + (pieSize / 8)
    
    //nothing
    let nothingOrigin = CGPoint(x: 0, y: (totalHeight / 2) - (pieSize / 4))
    let nothingSize = CGSize(width: totalWidth, height: pieSize / 2)
    nothingHereLabel = UILabel(frame: CGRect(origin: nothingOrigin, size: nothingSize))
    nothingHereLabel.numberOfLines = 0
    nothingHereLabel.text = "NOTHING HERE YET"
    nothingHereLabel.font = nothingHereLabel.font.withSize(50).italic()
    nothingHereLabel.adjustsFontSizeToFitWidth = true
    nothingHereLabel.textAlignment = .center
    nothingHereLabel.isHidden = true
    view.addSubview(nothingHereLabel)
    
    // backdrop
    let backdropOrigin = CGPoint(x: -totalWidth, y: (totalHeight / 2) - (pieSize / 2))
    let backdropSize = CGSize(width: totalWidth, height: coveringSize)
    
    backdrop = UIView(frame: CGRect(origin: backdropOrigin, size: backdropSize))
    backdrop.backgroundColor = .black
    
    let backdropTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleBackdropTap(gestureRecognizer:)))
    backdrop.addGestureRecognizer(backdropTap)
    
    textField = UITextField(frame: CGRect(x: totalWidth * 0.1, y: (coveringSize / 2) - (pieSize / 4), width: totalWidth * 0.8, height: pieSize / 2))
    textField.placeholder = "CODE"
    textField.font = UIFont.systemFont(ofSize: 50).italic()
    textField.textColor = .white
    textField.borderStyle = .none
    textField.autocorrectionType = .no
    textField.autocapitalizationType = .allCharacters
    textField.keyboardType = .default
    textField.returnKeyType = .done
    textField.clearButtonMode = .whileEditing;
    textField.contentVerticalAlignment = .center
    textField.contentHorizontalAlignment = .center
    textField.tintColor = .white
    textField.delegate = self
    
    backdrop.addSubview(textField)
    view.addSubview(backdrop)
    
    // loading
    let loadingOrigin = CGPoint(x: -totalWidth, y: (totalHeight / 2) - (pieSize / 2))
    let loadingSize = CGSize(width: totalWidth, height: coveringSize)
    loadingScreen = UIView(frame: CGRect(origin: loadingOrigin, size: loadingSize))
    loadingScreen.backgroundColor = .blue
    let loadingLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: loadingSize))
    loadingLabel.textColor = .white
    loadingLabel.text = "THINKING"
    loadingLabel.font = loadingLabel.font.withSize(50).italic()
    loadingLabel.adjustsFontSizeToFitWidth = true
    loadingLabel.textAlignment = .center
    loadingScreen.addSubview(loadingLabel)
    view.addSubview(loadingScreen)
    
    let origin = CGPoint(x: totalWidth / 2 - (pieSize * 0.8) / 2, y: totalHeight / 2 - (pieSize * 0.8) / 2)
    let size = CGSize(width: pieSize * 0.8, height: pieSize * 0.8)
    playButton = Circle(frame: CGRect(origin: origin, size: size))
    
    // reload button
    reloadButton = UIView(frame: CGRect(origin: CGPoint(x: screenCenterX - (pieSize / 8), y: totalHeight * 0.20), size: CGSize(width: pieSize / 4, height: pieSize / 4)))
    let reloadLabel = UILabel(frame: CGRect(x: 0, y: 0, width: pieSize / 4, height: pieSize / 4))
    reloadLabel.text = "↺"
    reloadLabel.adjustsFontSizeToFitWidth = true
    reloadLabel.font = reloadLabel.font.withSize(50).italic()
    reloadButton.addSubview(reloadLabel)
    let reloadTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleReloadTap(gestureRecognizer:)))
    reloadButton.addGestureRecognizer(reloadTap)
    view.addSubview(reloadButton)
    
    // randomize button
    randomizeButton = UIView(frame: CGRect(origin: CGPoint(x: (screenCenterX * 1.50) - (pieSize / 8), y: totalHeight * 0.20 - 2.5), size: CGSize(width: pieSize / 4, height: pieSize / 4)))
    let randomizeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: pieSize / 4, height: pieSize / 4))
    randomizeLabel.text = "⚄"
    randomizeLabel.adjustsFontSizeToFitWidth = true
    randomizeLabel.font = randomizeLabel.font.withSize(50).italic()
    randomizeButton.addSubview(randomizeLabel)
    let randomizeTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleRandomizeTap(gestureRecognizer:)))
    randomizeButton.addGestureRecognizer(randomizeTap)
    view.addSubview(randomizeButton)
    
    // download button
    downloadButton = UIView(frame: CGRect(origin: CGPoint(x: (screenCenterX * 1.50) - (pieSize / 8), y: totalHeight * 0.75), size: CGSize(width: pieSize / 4, height: pieSize / 4)))
    let downloadLabel = UILabel(frame: CGRect(x: 0, y: 0, width: pieSize / 4, height: pieSize / 4))
    downloadLabel.text = "↓"
    downloadLabel.adjustsFontSizeToFitWidth = true
    downloadLabel.font = downloadLabel.font.withSize(50).italic()
    downloadButton.addSubview(downloadLabel)
    let downloadTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleDownloadTap(gestureRecognizer:)))
    downloadButton.addGestureRecognizer(downloadTap)
    view.addSubview(downloadButton)
    
    // link button
    linkButton = UIView(frame: CGRect(origin: CGPoint(x: (screenCenterX * 0.5) - (pieSize / 8), y: totalHeight * 0.75), size: CGSize(width: pieSize / 4, height: pieSize / 4)))
    let linkLabel = UILabel(frame: CGRect(x: 0, y: 0, width: pieSize / 4, height: pieSize / 4))
    linkLabel.text = "☍"
    linkLabel.adjustsFontSizeToFitWidth = true
    linkLabel.font = linkLabel.font.withSize(50).italic()
    linkButton.addSubview(linkLabel)
    let linkTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleLinkTap(gestureRecognizer:)))
    linkButton.addGestureRecognizer(linkTap)
    view.addSubview(linkButton)
    
    // workingLabel
    let top = screenCenterY + (pieSize / 2)
    workingLabel = UILabel(frame: CGRect(x: 0, y: top, width: totalWidth, height: pieSize / 8))
    workingLabel.numberOfLines = 0
    workingLabel.textAlignment = .center
    workingLabel.font = workingLabel.font.italic()
    workingLabel.isHidden = true
    view.addSubview(workingLabel)
    
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
    configurePieHolder()
    
    // get chains
    fetchChains(nil, completedCallback: { chains, amount in
      self.createPies(chains: chains, callback: nil)
    }, failedCallback: { status in
      showAlert(context: self, message: "failed to contact the server")
    });
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func showBackdrop(_ showCompleted: (() -> Void)? = nil) {
    view.bringSubview(toFront: backdrop)
    
    UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
      self.backdrop.frame.origin.x = 0
    }, completion: { completed in
      if showCompleted != nil {
        showCompleted!()
      }
    })
  }
  
  func hideBackdrop(_ hideCompleted: (() -> Void)? = nil) {
    UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
      self.backdrop.frame.origin.x = self.backdrop.frame.origin.x - self.totalWidth
    }, completion: { completed in
      self.textField.resignFirstResponder();
      
      if hideCompleted != nil {
        hideCompleted!()
      }
    })
  }
  
  func showLoading(_ showCompleted: (() -> Void)? = nil) {
    view.bringSubview(toFront: loadingScreen)
    
    UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
      self.loadingScreen.frame.origin.x = 0
    }, completion: { completed in
      if showCompleted != nil {
        showCompleted!()
      }
    })
  }
  
  func hideLoading(_ hideCompleted: (() -> Void)? = nil) {
    UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
      self.loadingScreen.frame.origin.x = self.loadingScreen.frame.origin.x - self.totalWidth
    }, completion: { completed in
      if hideCompleted != nil {
        hideCompleted!()
      }
    })
  }
  
  func setActions() {
    let actionSize = pieSize / 4
    let x = (totalWidth / 2) - (actionSize / 2)
    let y = totalHeight * 0.75
    
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
    let link = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let linkLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    linkLabel.text = "☍"
    link.addSubview(linkLabel)
    link.addTarget(self, action: #selector(PlayController.openLink(sender:)), for: .touchUpInside)
    
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    button.backgroundColor = UIColor.red
    button.layer.cornerRadius = 10
    button.addTarget(self, action: #selector(PlayController.toNewRecording(sender:)), for: .touchUpInside)
    
    let recordIt = UIBarButtonItem(customView: button)
    let linkIt = UIBarButtonItem(customView: link)
    
    self.navigationItem.rightBarButtonItem = recordIt
    self.navigationItem.leftBarButtonItem = linkIt
  }
  
  func configurePieHolder() {
    piesHolderHeight.constant = pieSize
    
    // for some reason we require left and right swipe definitions? 🤔
    lsg = UISwipeGestureRecognizer(target: self, action: #selector(PlayController.handleSwipe(gestureRecognizer:)))
    rsg = UISwipeGestureRecognizer(target: self, action: #selector(PlayController.handleSwipe(gestureRecognizer:)))
    
    lsg!.direction = .left
    rsg!.direction = .right
    
    piesHolder.addGestureRecognizer(lsg!)
    piesHolder.addGestureRecognizer(rsg!)
  }
  
  func toNewRecording(sender: AnyObject) {
    let recorder: RecordingController = self.storyboard?.instantiateViewController(withIdentifier: "RecordingController") as! RecordingController
    
    recorder.creationCallback = { data in
      self.showLoading({
        createChain(data: data, completedCallback: { chain in
          var chains = self.chains()
          
          chains.insert(chain, at: self.currentPieIndex)
          
          self.createPies(chains: chains, callback: {
            self.hideLoading()
          })
        }, failedCallback: { status in
        })
      })
    }
    
    self.navigationController!.present(recorder, animated: true, completion: {})
  }
  
  func chains() -> [Chain] {
    return pies.map({ pie in pie.chain! })
  }
  
  func createPies(chains: [Chain], callback: (() -> Void)?) {
    var offset = (x: piesHolder.center.x - (pieSize / 2) - (CGFloat(currentPieIndex) * (piesHolder.bounds.width / 2)
      ), y: CGFloat(0.0))
    
    piesHolder.subviews.forEach({ $0.removeFromSuperview() })
    pies.removeAll()
    
    for c in chains {
      let p = Pie(chain: c, origin: offset, size: pieSize)
      
      pies.append(p)
      
      let newX = offset.x + (piesHolder.bounds.width / 2)
      let newY = offset.y
      
      offset = (x: newX, y: newY)
    }
    
    renderPies({
      self.loadChain({
        if callback != nil {
          callback!()
        }
      })
    })
  }
  
  func renderPies(_ callback: (() -> Void)?) {
    if pies.count == 0 {
      nothingHereLabel.isHidden = false
      view.bringSubview(toFront: nothingHereLabel)
    } else {
      nothingHereLabel.isHidden = true
    }
    
    for p in pies {
      piesHolder.addSubview(p)
    }
    
    if callback != nil {
      callback!()
    }
  }
  
  func enablePieForChain(chain: Chain) {
    if let pie = pieForChain(chain: chain) {
      pie.enable()
    }
  }
  
  func disablePieForChain(chain: Chain) {
    if let pie = pieForChain(chain: chain) {
      pie.disable()
    }
  }
  
  func pieForChain(chain: Chain) -> Pie? {
    if let index = pies.index(where: { pie in return pie.chain != nil && pie.chain!.id == chain.id }) {
      return pies[index]
    } else {
      return nil
    }
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
    timer!.invalidate()
    playing = false
    setPlayButtonState(to: .stopped)
    setPlayProgress()
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
    stopPlaying()
    disableControls()
    pies[currentPieIndex].removeGestureRecognizer(pieTap!)
  }
  
  func loadChain(_ callback: (() -> Void)? = nil) {
    var enabledControls = false
    
    if pies.count - 1 < currentPieIndex {
      enableReloadButton()
      return
    }
    
    if let chain = pies[currentPieIndex].chain {
      if chain.url == nil || chain.url! == "" {
        self.disableControls()
        self.pies[self.currentPieIndex].disable()
      } else {
        let url = "https://s3.us-east-2.amazonaws.com/tel-serv/" + chain.url!
        
        initAudio(url, callback: {
          self.pies[self.currentPieIndex].addGestureRecognizer(self.pieTap!)
          self.pies[self.currentPieIndex].enable()
          self.setPlayProgress()
          self.enableControls()
          
          enabledControls = true
        }, failure: {
          self.enableReloadButton()
        })
      }
      
      if chain.queuedBuildCount > 0 {
        workingLabel.text = "\(chain.queuedBuildCount)"
        workingLabel.isHidden = false
      } else {
        workingLabel.text = ""
        workingLabel.isHidden = true
      }
    } else {
      self.disableControls()
      self.pies[self.currentPieIndex].disable()
    }
    
    if !enabledControls {
      enableReloadButton()
    }
    
    if callback != nil {
      callback!()
    }
  }
  
  func initAudio(_ url: String, callback: @escaping () -> Void, failure: @escaping () -> Void) {
    if let data = audioCache[url] {
      do {
        try self.audio = AVAudioPlayer(data: data)
        self.audio!.delegate = self
        self.audio!.prepareToPlay()
        self.percentDivisor = 360 / self.audio!.duration
        callback()
      } catch {
        failure()
      }
    } else {
      Alamofire.request(url).responseData(completionHandler: { dataResponse in
        if dataResponse.data != nil {
          do {
            try self.audio = AVAudioPlayer(data: dataResponse.data!)
            self.audio!.delegate = self
            self.audio!.prepareToPlay()
            self.percentDivisor = 360 / self.audio!.duration
            self.audioCache[url] = dataResponse.data!
            callback()
          } catch {
            failure()
          }
        }
      })
    }
  }
  
  func openLink(sender: AnyObject) {
    textField.isUserInteractionEnabled = true
    textField.text = nil
    textField.becomeFirstResponder()
    showBackdrop()
  }
  
  func handleBackdropTap(gestureRecognizer: UILongPressGestureRecognizer) {
    hideBackdrop()
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
  
  func handleReloadTap(gestureRecognizer: UITapGestureRecognizer) {
    showLoading({
      fetchChain(chain: self.pies[self.currentPieIndex].chain!, completedCallback: { chain in
        self.hideLoading({
          var currentChains = self.chains()
          
          if let index = currentChains.index(where: { someChain in someChain.id == chain.id }) {
            currentChains[index] = chain
            
            self.hideLoading({
              self.createPies(chains: currentChains, callback: {
                self.setPlayProgress(zero: true)
              })
            })
          }
        })
      }, failedCallback: { status in
        self.hideLoading({
          showAlert(context: self, message: "failed to contact the server")
        })
      })
    })
  }
  
  func handleRandomizeTap(gestureRecognizer: UITapGestureRecognizer) {
    showLoading({
      fetchChains(nil, completedCallback: { chains, amount in
        self.hideLoading({
          self.createPies(chains: chains, callback: nil)
        })
      }, failedCallback: { status in
        self.hideLoading({
          showAlert(context: self, message: "failed to contact the server")
        })
      });
    })
  }
  
  func handleDownloadTap(gestureRecognizer: UITapGestureRecognizer) {
    let alertController = UIAlertController(title: nil, message: "what do you want to save?", preferredStyle: .actionSheet)
    
    let wholeThing = UIAlertAction(title: "the whole chain", style: .default, handler: nil)
    let justSound = UIAlertAction(title: "just the current sound", style: .default, handler: nil)
    let cancelThisShit = UIAlertAction(title: "get outta here", style: .destructive, handler: nil)
    
    alertController.addAction(wholeThing)
    alertController.addAction(justSound)
    alertController.addAction(cancelThisShit)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  func handleLinkTap(gestureRecognizer: UITapGestureRecognizer) {
    textField.isUserInteractionEnabled = false
    textField.text = pies[currentPieIndex].chain!.code
    showBackdrop()
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
    
    recorder.additionCallback = { data, chain in
      self.showLoading({
        createSound(data: data, chainId: chain.id, completedCallback: { chain in
          var currentChains = self.chains()
          
          if let index = currentChains.index(where: { someChain in someChain.id == chain.id }) {
            currentChains[index] = chain
            
            self.hideLoading({
              self.createPies(chains: currentChains, callback: {
                self.setPlayProgress(zero: true)
              })
            })
          }
        }, failedCallback: { status in
        })
      })
    }
    
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
      
      UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
        for view in self.piesHolder.subviews {
          view.frame.origin.x = view.frame.origin.x + newX
        }
      }, completion: { success in
        self.loadChain()
      })
    } else {
      let bounceValue = gestureRecognizer.direction == .left ? -(pieSize / 4) : pieSize / 4
      
      self.disableControls()
      
      UIView.animate(withDuration: 0.10, delay: 0.0, options: .curveEaseInOut, animations: {
        for view in self.piesHolder.subviews {
          view.frame.origin.x = view.frame.origin.x + CGFloat(bounceValue)
        }
      }, completion: { completed in
        UIView.animate(withDuration: 0.10, delay: 0.0, options: .curveEaseInOut, animations: {
          for view in self.piesHolder.subviews {
            view.frame.origin.x = view.frame.origin.x - CGFloat(bounceValue)
          }
        }, completion: { completed in
          self.loadChain()
        })
      })
    }
  }
  
  func enableReloadButton() {
    if pies.count > 0 {
      reloadButton.layer.opacity = 1.0
      reloadButton.isUserInteractionEnabled = true
    }
    
    randomizeButton.layer.opacity = 1.0
    randomizeButton.isUserInteractionEnabled = true
  }
  
  func enableControls() {
    progress.strokeColor = UIColor.black.cgColor
    playButton.backgroundColor = .white
    record.layer.opacity = 1.0
    playButton.layer.opacity = 1.0
    linkButton.layer.opacity = 1.0
    reloadButton.layer.opacity = 1.0
    downloadButton.layer.opacity = 1.0
    randomizeButton.layer.opacity = 1.0
    record.isUserInteractionEnabled = true
    playButton.isUserInteractionEnabled = true
    linkButton.isUserInteractionEnabled = true
    reloadButton.isUserInteractionEnabled = true
    downloadButton.isUserInteractionEnabled = true
    randomizeButton.isUserInteractionEnabled = true
    record.layer.opacity = 1.0
    
    progress.removeFromSuperlayer()
    view.layer.addSublayer(progress)
    view.bringSubview(toFront: self.playButton)
  }
  
  func disableControls() {
    workingLabel.isHidden = true
    progress.strokeColor = UIColor.clear.cgColor
    playButton.backgroundColor = .clear
    record.layer.opacity = 0.5
    playButton.layer.opacity = 0.5
    linkButton.layer.opacity = 0.5
    reloadButton.layer.opacity = 0.5
    downloadButton.layer.opacity = 0.5
    randomizeButton.layer.opacity = 0.5
    record.isUserInteractionEnabled = false
    playButton.isUserInteractionEnabled = false
    linkButton.isUserInteractionEnabled = false
    reloadButton.isUserInteractionEnabled = false
    downloadButton.isUserInteractionEnabled = false
    randomizeButton.isUserInteractionEnabled = false
    
    view.bringSubview(toFront: self.piesHolder)
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
  
  func setPlayProgress(zero: Bool = false) {
    var time: Double? = nil
    
    if zero {
      time = 0.0
    } else if audio != nil {
      time = audio!.currentTime
    }
    
    if time != nil {
      let angle = CGFloat(percentDivisor * time!)
      updateProgress(angle: angle)
    }
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if range.location >= 4 {
      return false;
    } else {
      return true;
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder();
    return true;
  }
}
