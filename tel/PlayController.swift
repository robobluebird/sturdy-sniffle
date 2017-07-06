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
  var piesHolder = UIView()
  var playButton = UIView()
  var playButtonGraphic = UIView()
  var loadingScreen = UIView()
  var backdrop = UIView()
  var reloadButton = UIView()
  var randomizeButton = UIView()
  var downloadButton = UIView()
  var linkButton = UIView()
  var singleSegmentDownloadButton = UIView()
  var wholeChainDownloadButton = UIView()
  var submitCodeButton = UIView()
  var downloadChooser = UIView()
  var codeInput = UIView()
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
  var piePan: UIPanGestureRecognizer?
  var panStartPoint = CGPoint()
  var audioWasPlayingWhenPanGestureBegan = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let coveringSize = pieSize + (pieSize / 8)
    
    // piesHolder
    piesHolder = UIView(frame: CGRect(x: 0, y: screenCenterY - pieSize / 2, width: totalWidth, height: pieSize))
    view.addSubview(piesHolder)
    
    // nothing
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
    backdrop = UIView(frame: CGRect(x: -totalWidth, y: 0, width: totalWidth, height: totalHeight))
    backdrop.backgroundColor = .clear
    
    let backdropTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleBackdropTap(gestureRecognizer:)))
    backdrop.addGestureRecognizer(backdropTap)
    
    let foredropOrigin = CGPoint(x: 0, y: (totalHeight / 2) - (pieSize / 2))
    let foredropSize = CGSize(width: totalWidth, height: coveringSize)
    
    // code input
    codeInput = UIView(frame: CGRect(origin: foredropOrigin, size: foredropSize))
    codeInput.backgroundColor = .black
    
    backdrop.addSubview(codeInput)
    
    textField = UITextField(frame: CGRect(x: totalWidth * 0.1, y: (coveringSize / 2) - (pieSize / 4), width: totalWidth * 0.6, height: pieSize / 2))
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
    
    submitCodeButton = UIView(frame: CGRect(x: totalWidth * 0.7, y: (coveringSize / 2) - ((totalWidth * 0.2) / 2), width: totalWidth * 0.2, height: totalWidth * 0.2))
    let go = InterestingView(frame: CGRect(x: 0, y: 0, width: totalWidth * 0.2, height: totalWidth * 0.2), shape: Shape.ok, color: UIColor.green)
    go.backgroundColor = UIColor.clear
    submitCodeButton.addSubview(go)
    let submitCodeAction = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleSubmitCodeButtonTap(gestureRecognizer:)))
    submitCodeButton.addGestureRecognizer(submitCodeAction)
    
    codeInput.addSubview(textField)
    codeInput.addSubview(submitCodeButton)
    
    // download chooser
    downloadChooser = UIView(frame: CGRect(origin: foredropOrigin, size: foredropSize))
    downloadChooser.backgroundColor = .black
    backdrop.addSubview(downloadChooser)
    
    // download buttons
    singleSegmentDownloadButton = UIView(frame: CGRect(x: totalWidth * 0.2, y: (coveringSize / 2) - ((totalWidth * 0.2) / 2), width: totalWidth * 0.2, height: totalWidth * 0.2))
    
    let singleSegmentTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleSingleSegmentButtonTap(gestureRecognizer:)))
    singleSegmentDownloadButton.addGestureRecognizer(singleSegmentTap)
    
    wholeChainDownloadButton = UIView(frame: CGRect(x: totalWidth * 0.6, y: (coveringSize / 2) - ((totalWidth * 0.2) / 2), width: totalWidth * 0.2, height: totalWidth * 0.2))
    
    let wholeChainTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleWholeChainButtonTap(gestureRecognizer:)))
    wholeChainDownloadButton.addGestureRecognizer(wholeChainTap)
    
    var segmentIconLayers = [CAShapeLayer]()
    var wholeIconLayers = [CAShapeLayer]()
    var startAngle = CGFloat(0)
    let radius = ((totalWidth * 0.2) / 2)
    
    for i in 1...4 {
      let segmentLayer = CAShapeLayer()
      let wholeLayer = CAShapeLayer()
      
      let endAngle = CGFloat(90 * i)
      
      let segmentPath = UIBezierPath(
        circleSegmentCenter: CGPoint(x: radius, y: radius),
        radius: radius,
        startAngle: CGFloat(startAngle),
        endAngle: endAngle
      )
      
      let wholePath = UIBezierPath(
        circleSegmentCenter: CGPoint(x: radius, y: radius),
        radius: radius,
        startAngle: CGFloat(startAngle),
        endAngle: endAngle
      )
      
      segmentLayer.path = segmentPath.cgPath
      segmentLayer.fillColor = UIColor.white.cgColor
      segmentLayer.strokeColor = UIColor.black.cgColor
      segmentLayer.lineWidth = 2
      
      if i > 1 {
        segmentLayer.opacity = 0.2
      }
      
      wholeLayer.path = wholePath.cgPath
      wholeLayer.fillColor = UIColor.white.cgColor
      wholeLayer.strokeColor = UIColor.black.cgColor
      wholeLayer.lineWidth = 2
      
      segmentIconLayers.append(segmentLayer)
      wholeIconLayers.append(wholeLayer)
      
      startAngle += 90
    }
    
    for layer in segmentIconLayers {
      singleSegmentDownloadButton.layer.addSublayer(layer)
    }
    
    for layer in wholeIconLayers {
      wholeChainDownloadButton.layer.addSublayer(layer)
    }
    
    singleSegmentDownloadButton.backgroundColor = .clear
    wholeChainDownloadButton.backgroundColor = .clear
    
    let singleSegmentCoverPie = Circle(frame: CGRect(x: totalWidth * 0.2 * 0.075, y: totalWidth * 0.2 * 0.075, width: totalWidth * 0.2 * 0.85, height: totalWidth * 0.2 * 0.85))
    singleSegmentCoverPie.backgroundColor = .black
    singleSegmentDownloadButton.addSubview(singleSegmentCoverPie)
    
    downloadChooser.addSubview(singleSegmentDownloadButton)
    
    let wholeChainCoverPie = Circle(frame: CGRect(x: totalWidth * 0.2 * 0.075, y: totalWidth * 0.2 * 0.075, width: totalWidth * 0.2 * 0.85, height: totalWidth * 0.2 * 0.85))
    wholeChainCoverPie.backgroundColor = .black
    wholeChainDownloadButton.addSubview(wholeChainCoverPie)
    
    downloadChooser.addSubview(wholeChainDownloadButton)
    
    // add the whole backdrop + foredrops
    view.addSubview(backdrop)
    
    // loading
    let loadingOrigin = CGPoint(x: -totalWidth, y: (totalHeight / 2) - (pieSize / 2))
    let loadingSize = CGSize(width: totalWidth, height: coveringSize)
    loadingScreen = UIView(frame: CGRect(origin: loadingOrigin, size: loadingSize))
    loadingScreen.backgroundColor = .black
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
    
    // pie pan
    piePan = UIPanGestureRecognizer(target: self, action: #selector(PlayController.handlePiePan(gestureRecognizer:)))
    
    // tap for play button
    tg = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleTap(gestureRecognizer:)))
    
    playButton.addGestureRecognizer(tg!)
    
    // progress
    progress = progressPie()
    progress.isHidden = true
    
    // audio
    configureAudioSession()
    
    // nav
    setNavigationItems()
    
    // actions
    setActions()
    disableControls()
    configurePieHolder()
    
    register(registeredCallback: {
      fetchChains(nil, completedCallback: { chains, amount in
        self.createPies(chains: chains, callback: nil)
      }, failedCallback: { status in
        handleErrorCode(code: status ?? -1, alertContext: self)
      });
    }, notRegisteredCallback: { status in
    })
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func showCodeInput() {
    backdrop.bringSubview(toFront: codeInput)
    showBackdrop()
  }
  
  func showDownloadChooser() {
    backdrop.bringSubview(toFront: downloadChooser)
    showBackdrop()
  }
  
  func showBackdrop(_ showCompleted: (() -> Void)? = nil) {
    view.bringSubview(toFront: backdrop)
    
    UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
      self.backdrop.frame.origin.x = 0
    }, completion: { completed in
      if showCompleted != nil {
        showCompleted!()
      }
    })
  }
  
  func hideBackdrop(_ hideCompleted: (() -> Void)? = nil) {
    UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
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
    
    UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
      self.loadingScreen.frame.origin.x = 0
    }, completion: { completed in
      if showCompleted != nil {
        showCompleted!()
      }
    })
  }
  
  func hideLoading(_ hideCompleted: (() -> Void)? = nil) {
    UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
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
          
          self.hideLoading({
            self.createPies(chains: chains, callback: {})
          })
        }, failedCallback: { status in
          self.hideLoading({
            handleErrorCode(code: status ?? -1, alertContext: self)
          })
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
      playButton.isHidden = true
      workingLabel.text = ""
      workingLabel.isHidden = true
    } else {
      nothingHereLabel.isHidden = true
      playButton.isHidden = false
    }
    
    for p in pies {
      p.maybeDisable()
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
  
  func updateProgress(degreeAngle: CGFloat) {
    let radians = (degreeAngle - 90) * (CGFloat(M_PI) / 180)
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
    pies[currentPieIndex].removeGestureRecognizer(piePan!)
    pies[currentPieIndex].rotateTo(degreeAngle: 0)
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
          self.pies[self.currentPieIndex].addGestureRecognizer(self.piePan!)
          self.pies[self.currentPieIndex].enable()
          self.setPlayProgress()
          self.enableControls()
          
          enabledControls = true
        }, failure: {
          handleErrorCode(code: 437, alertContext: self)
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
    submitCodeButton.isHidden = false
    submitCodeButton.layer.opacity = 0.5
    textField.isUserInteractionEnabled = true
    textField.text = nil
    textField.placeholder = "CODE"
    textField.becomeFirstResponder()
    showCodeInput()
  }
  
  func handleSubmitCodeButtonTap(gestureRecognizer: UITapGestureRecognizer) {
    let code = textField.text!
    
    hideBackdrop({
      if code.characters.count == 4 {
        if let pieIndex = self.findPieIndexByCode(code) {
          self.scrollToPie(atIndex: pieIndex)
        } else {
          self.showLoading({
            fetchChainByCode(code: code, completedCallback: { chain in
              var chains = self.chains()
              
              chains.insert(chain, at: self.currentPieIndex)
              
              self.createPies(chains: chains, callback: {
                self.hideLoading()
              })
            }, failedCallback: { status in
              self.hideLoading({
                handleErrorCode(code: status ?? -1, alertContext: self)
              })
            })
          })
        }
      }
    })
  }
  
  func soundForCurrentPlayTime() -> Sound? {
    if audio != nil && pies[currentPieIndex].chain != nil {
      let time = audio!.currentTime
      var segmentTime = 0.0
      
      for sound in pies[currentPieIndex].chain!.sounds {
        if time >= segmentTime && time < segmentTime + Double(sound.duration) {
          return sound
        } else {
          segmentTime += Double(sound.duration)
        }
      }
    }
    
    return nil
  }
  
  func handleSingleSegmentButtonTap(gestureRecognizer: UITapGestureRecognizer) {
    if let sound = soundForCurrentPlayTime() {
      Alamofire.request(sound.url).responseData(completionHandler: { dataResponse in
        if let data = dataResponse.data {
          let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
          self.present(av, animated: true, completion: nil)
        }
      })
    }
  }
  
  func handleWholeChainButtonTap(gestureRecognizer: UITapGestureRecognizer) {
    if audio != nil {
      if let data = audio!.data {
        let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        self.present(av, animated: true, completion: nil)
      }
    }
  }
  
  func findPieIndexByCode(_ code: String) -> Int? {
    if let index = chains().index(where: { chain in chain.code == code }) {
      return index
    } else {
      return nil
    }
  }
  
  func scrollToPie(atIndex index: Int) {
    let currentOffset = CGFloat(currentPieIndex) * screenCenterX
    let desiredOffset = CGFloat(index) * screenCenterX
    let scrollAmount = currentOffset - desiredOffset
    
    unloadChain()
    
    currentPieIndex = index
    
    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
      for view in self.piesHolder.subviews {
        view.frame.origin.x = view.frame.origin.x + scrollAmount
      }
    }, completion: { success in
      self.loadChain()
    })
  }
  
  func handleBackdropTap(gestureRecognizer: UITapGestureRecognizer) {
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
          handleErrorCode(code: status ?? -1, alertContext: self)
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
          handleErrorCode(code: status ?? -1, alertContext: self)
        })
      });
    })
  }
  
  func handleDownloadTap(gestureRecognizer: UITapGestureRecognizer) {
    showDownloadChooser()
  }
  
  func handleLinkTap(gestureRecognizer: UITapGestureRecognizer) {
    textField.isUserInteractionEnabled = false
    textField.text = pies[currentPieIndex].chain!.code
    submitCodeButton.isHidden = true
    submitCodeButton.isUserInteractionEnabled = false
    showCodeInput()
  }
  
  func handlePieTap(gestureRecognizer: UITapGestureRecognizer) {
    let point = gestureRecognizer.location(in: pies[currentPieIndex])
    let time = pies[currentPieIndex].startTimeForPiePieceCoveringPoint(point: point)
    var wasPlaying = false
    
    if audio!.isPlaying {
      audio!.pause()
      wasPlaying = true
    }
    
    audio!.currentTime = TimeInterval(time)
    setPlayProgress()
    
    if wasPlaying {
      audio!.play()
    }
  }
  
  func handlePiePan(gestureRecognizer: UIPanGestureRecognizer) {
    if audio != nil {
      if gestureRecognizer.state == .began {
        if audio!.isPlaying {
          audioWasPlayingWhenPanGestureBegan = true
          audio!.pause()
        }
        
        panStartPoint = gestureRecognizer.location(in: view)
      } else if gestureRecognizer.state == .ended {
        if audioWasPlayingWhenPanGestureBegan {
          audio!.play()
          audioWasPlayingWhenPanGestureBegan = false
        }
      } else {
        let newPoint = gestureRecognizer.location(in: view)
        let startPointAngle = atan2(panStartPoint.y - screenCenterY, panStartPoint.x - screenCenterX)
        let newPointAngle = atan2(newPoint.y - screenCenterY, newPoint.x - screenCenterX)
        let angle = (newPointAngle - startPointAngle) * 180 / CGFloat(M_PI)
        
        pies[currentPieIndex].rotateBy(degreeAngle: angle)
        adjustAudioProgress(by: -(Double(angle / 360) * audio!.duration))
        
        panStartPoint = newPoint
      }
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
          self.hideLoading({
            handleErrorCode(code: status ?? -1, alertContext: self)
          })
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
        newX = newX - screenCenterX
        pieChange += 1
      }
    } else if gestureRecognizer.direction == .right {
      if currentPieIndex > 0 {
        newX = newX + screenCenterX
        pieChange -= 1
      }
    }
    
    if newX != 0.0 {
      self.unloadChain()
      
      currentPieIndex += pieChange
      
      UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
        for view in self.piesHolder.subviews {
          view.frame.origin.x = view.frame.origin.x + newX
        }
      }, completion: { success in
        self.loadChain()
      })
    } else {
      let bounceValue = gestureRecognizer.direction == .left ? -(pieSize / 4) : pieSize / 4
      
      self.disableControls()
      
      UIView.animate(withDuration: 0.10, delay: 0.0, options: .curveLinear, animations: {
        for view in self.piesHolder.subviews {
          view.frame.origin.x = view.frame.origin.x + CGFloat(bounceValue)
        }
      }, completion: { completed in
        UIView.animate(withDuration: 0.10, delay: 0.0, options: .curveEaseOut, animations: {
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
  
  func disableControls(changeOpacity: Bool = false) {
    workingLabel.isHidden = true
    progress.strokeColor = UIColor.clear.cgColor
    playButton.backgroundColor = .clear
    
    if changeOpacity {
      record.layer.opacity = 0.5
      playButton.layer.opacity = 0.5
      linkButton.layer.opacity = 0.5
      reloadButton.layer.opacity = 0.5
      downloadButton.layer.opacity = 0.5
      randomizeButton.layer.opacity = 0.5
    }
    
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
      audio!.numberOfLoops = -1
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
      pies[currentPieIndex].rotateTo(degreeAngle: angle)
    }
  }
  
  func adjustAudioProgress(by time: Double) {
    var newTime = audio!.currentTime + time
    
    if newTime < 0 {
      newTime = audio!.duration + newTime
    }
    
    audio!.currentTime = newTime
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text else { return true }
    let newLength = text.characters.count + string.characters.count - range.length
    
    if newLength == 4 {
      submitCodeButton.layer.opacity = 1.0
      submitCodeButton.isUserInteractionEnabled = true
    } else {
      submitCodeButton.layer.opacity = 0.5
      submitCodeButton.isUserInteractionEnabled = false
    }
    
    return newLength <= 4
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder();
    return true;
  }
}
