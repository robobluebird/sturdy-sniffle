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
import MediaPlayer

class PlayController: UIViewController, AVAudioPlayerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate{
  var percentDivisor = 0.0
  var tg: UITapGestureRecognizer?
  var lsg: UISwipeGestureRecognizer?
  var rsg: UISwipeGestureRecognizer?
  var pblsg: UISwipeGestureRecognizer?
  var pbrsg: UISwipeGestureRecognizer?
  var audioTimer = Timer()
  var loadingTimer = Timer()
  var playingRate = 0.0
  var audio: AVAudioPlayer?
  var soundPoints: [Float] = []
  var pies: [Pie] = []
  var currentPieIndex = 0
  var playing = false
  var positionIndicator = UIView()
  var record = UIView()
  var piesHolder = UIView()
  var playButton = UIView()
  var playButtonGraphic = UIView()
  var loadingBackdrop = UIView()
  var loadingScreen = UIView()
  var backdrop = UIView()
  var reloadButton = UIView()
  var randomizeButton = UIView()
  var starredButton = UIView()
  var tokenButton = UIView()
  var downloadButton = UIView()
  var starButton = UIView()
  var starLabel = UILabel()
  var codeLabel = UILabel()
  var singleSegmentDownloadButton = UIView()
  var wholeCircleDownloadButton = UIView()
  var submitCodeButton = UIView()
  var downloadChooser = UIView()
  var codeInput = UIView()
  var nothingHereLabel = UILabel()
  var workingLabel = UILabel()
  var textField = UITextField()
  let totalWidth = UIScreen.main.bounds.width
  let totalHeight = UIScreen.main.bounds.height
  let screenCenterX = UIScreen.main.bounds.width / 2
  let screenCenterY = UIScreen.main.bounds.height / 2
  let pieSize = UIScreen.main.bounds.width / 2
  var audioCache = [String: Data]()
  var pieTap: UITapGestureRecognizer?
  var piePan: UIPanGestureRecognizer?
  var pieLongPress: UILongPressGestureRecognizer?
  var panStartPoint = CGPoint()
  var newCircleButton = UIBarButtonItem()
  var openLinkButton = UIBarButtonItem()
  var audioWasPlayingWhenPanGestureBegan = false
  var isPrepared = false
  var loadingLabel20 = UILabel()
  var loadingLabel40 = UILabel()
  var loadingLabel60 = UILabel()
  var loadingLabel80 = UILabel()
  
  let cosImage = UIImage(named: "circle")!
  let recordImage = UIImage(named: "recordcircle")
  let reloadImage = UIImage(named: "reload")
  let randomImage = UIImage(named: "huh")
  let downloadImage = UIImage(named: "splitdownloadarrow")
  let faceImage = UIImage(named: "face")
  let blackStarImage = UIImage(named: "blackstar")
  let blackStarSolidImage = UIImage(named: "blackstarsolid")
  let goldStarImage = UIImage(named: "goldstar")
  let goldStarSolidImage = UIImage(named: "goldstarsolid")
  let pencilImage = UIImage(named: "pencil")
  let smallRecordImage = UIImage(named: "smallrecordcircle")
  let linkImage = UIImage(named: "link")
  let underlineImage = UIImage(named: "underline")
  
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
    nothingHereLabel.font = nothingHereLabel.font.withSize(pieSize / 4).italic()
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
    textField.clearButtonMode = .whileEditing;
    textField.contentVerticalAlignment = .center
    textField.contentHorizontalAlignment = .center
    textField.tintColor = .white
    textField.delegate = self
    
    submitCodeButton = UIView(frame: CGRect(x: totalWidth * 0.7, y: (coveringSize / 2) - ((totalWidth * 0.2) / 2), width: totalWidth * 0.2, height: totalWidth * 0.2))
    let go = InterestingView(frame: CGRect(x: 0, y: 0, width: totalWidth * 0.2, height: totalWidth * 0.2), shape: Shape.ok, color: UIColor.green)
    go.backgroundColor = UIColor.clear
    submitCodeButton.addSubview(go)
    let submitCodeAction = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleSubmitCodeButtonTap))
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
    
    wholeCircleDownloadButton = UIView(frame: CGRect(x: totalWidth * 0.6, y: (coveringSize / 2) - ((totalWidth * 0.2) / 2), width: totalWidth * 0.2, height: totalWidth * 0.2))
    
    let wholeCircleTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleWholeCircleButtonTap(gestureRecognizer:)))
    wholeCircleDownloadButton.addGestureRecognizer(wholeCircleTap)
    
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
      wholeCircleDownloadButton.layer.addSublayer(layer)
    }
    
    singleSegmentDownloadButton.backgroundColor = .clear
    wholeCircleDownloadButton.backgroundColor = .clear
    
    let singleSegmentCoverPie = CircleView(frame: CGRect(x: totalWidth * 0.2 * 0.075, y: totalWidth * 0.2 * 0.075, width: totalWidth * 0.2 * 0.85, height: totalWidth * 0.2 * 0.85))
    singleSegmentCoverPie.backgroundColor = .black
    singleSegmentDownloadButton.addSubview(singleSegmentCoverPie)
    
    downloadChooser.addSubview(singleSegmentDownloadButton)
    
    let wholeCircleCoverPie = CircleView(frame: CGRect(x: totalWidth * 0.2 * 0.075, y: totalWidth * 0.2 * 0.075, width: totalWidth * 0.2 * 0.85, height: totalWidth * 0.2 * 0.85))
    wholeCircleCoverPie.backgroundColor = .black
    wholeCircleDownloadButton.addSubview(wholeCircleCoverPie)
    
    downloadChooser.addSubview(wholeCircleDownloadButton)
    
    // add the whole backdrop + foredrops
    view.addSubview(backdrop)
    
    // loading
    loadingBackdrop = UIView(frame: CGRect(x: -totalWidth, y: 0, width: totalWidth, height: totalHeight))
    loadingBackdrop.backgroundColor = .clear
    
    let loadingOrigin = CGPoint(x: 0, y: (totalHeight / 2) - (pieSize / 2))
    let loadingSize = CGSize(width: totalWidth, height: coveringSize)
    
    loadingScreen = UIView(frame: CGRect(origin: loadingOrigin, size: loadingSize))
    loadingScreen.backgroundColor = .black
    loadingBackdrop.addSubview(loadingScreen)
    
    createLoadingLabels(coveringSize)
    
    view.addSubview(loadingBackdrop)
    
    let origin = CGPoint(x: totalWidth / 2 - (pieSize * 0.75) / 2, y: totalHeight / 2 - (pieSize * 0.75) / 2)
    let size = CGSize(width: pieSize * 0.75, height: pieSize * 0.75)
    playButton = CircleView(frame: CGRect(origin: origin, size: size))
    
    // reload button
    reloadButton = UIImageView(image: reloadImage)
    reloadButton.frame = CGRect(origin: CGPoint(x: totalWidth * 0.2 - pieSize / 8, y: totalHeight * 0.75), size: CGSize(width: pieSize / 4, height: pieSize / 4))
    let reloadTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleReloadTap(gestureRecognizer:)))
    reloadButton.addGestureRecognizer(reloadTap)
    view.addSubview(reloadButton)
    
    // position indicator
    let heightDifference = pieSize / 3 - pieSize / 4
    positionIndicator = UIImageView(image: underlineImage)
    positionIndicator.frame = CGRect(origin: CGPoint(x: totalWidth * 0.75 - pieSize / 6, y: totalHeight * 0.20 - heightDifference / 4), size: CGSize(width: pieSize / 3, height: pieSize / 3))
    view.addSubview(positionIndicator)
    
    // randomize button
    randomizeButton = UIImageView(image: randomImage)
    randomizeButton.frame = CGRect(origin: CGPoint(x: (totalWidth * 0.75) - (pieSize / 8), y: totalHeight * 0.20), size: CGSize(width: pieSize / 4, height: pieSize / 4))
    let randomizeTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleRandomizeTap(gestureRecognizer:)))
    randomizeButton.addGestureRecognizer(randomizeTap)
    view.addSubview(randomizeButton)
    
    // starred button
    starredButton = UIImageView(image: blackStarImage)
    starredButton.frame = CGRect(origin: CGPoint(x: (totalWidth * 0.5) - (pieSize / 8), y: totalHeight * 0.20), size: CGSize(width: pieSize / 4, height: pieSize / 4))
    let starredTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleStarredTap(gestureRecognizer:)))
    starredButton.addGestureRecognizer(starredTap)
    view.addSubview(starredButton)
    
    // token button
    tokenButton = UIImageView(image: faceImage)
    tokenButton.frame = CGRect(origin: CGPoint(x: (totalWidth * 0.25) - (pieSize / 8), y: totalHeight * 0.20), size: CGSize(width: pieSize / 4, height: pieSize / 4))
    let tokenTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleTokenTap(gestureRecognizer:)))
    tokenButton.addGestureRecognizer(tokenTap)
    view.addSubview(tokenButton)
    
    // download button
    downloadButton = UIImageView(image: downloadImage)
    downloadButton.frame = CGRect(origin: CGPoint(x: (totalWidth * 0.6) - (pieSize / 8), y: totalHeight * 0.75), size: CGSize(width: pieSize / 4, height: pieSize / 4))
    let downloadTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleDownloadTap(gestureRecognizer:)))
    downloadButton.addGestureRecognizer(downloadTap)
    view.addSubview(downloadButton)
    
     // star button
    starButton = UIImageView(image: goldStarImage)
    starButton.frame = CGRect(origin: CGPoint(x: (totalWidth * 0.4) - (pieSize / 8), y: totalHeight * 0.75), size: CGSize(width: pieSize / 4, height: pieSize / 4))
    let starTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleStarButtonTap(gestureRecognizer:)))
    starButton.addGestureRecognizer(starTap)
    view.addSubview(starButton)
    
    // codeLabel
    let codeLabelTop = totalHeight * 0.75 + pieSize / 4 * 1.5
    codeLabel = UILabel(frame: CGRect(x: 0, y: codeLabelTop, width: totalWidth, height: pieSize / 8))
    codeLabel.numberOfLines = 0
    codeLabel.textAlignment = .center
    codeLabel.font = workingLabel.font.italic()
    codeLabel.text = ""
    view.addSubview(codeLabel)
    
    // workingLabel
    let workingLabelTop = screenCenterY + pieSize / 2 + (pieSize / 8)
    workingLabel = UILabel(frame: CGRect(x: 0, y: workingLabelTop, width: totalWidth, height: pieSize / 8))
    workingLabel.numberOfLines = 0
    workingLabel.textAlignment = .center
    workingLabel.font = workingLabel.font.italic()
    workingLabel.isHidden = true
    view.addSubview(workingLabel)
    
    // make the play button
    let triangle = InterestingView(frame: CGRect(x: 0, y: 0, width: pieSize * 0.25, height: pieSize * 0.25), shape: Shape.play)
    triangle.backgroundColor = UIColor.clear
    playButtonGraphic = UIView(frame: CGRect(origin: CGPoint(x: (pieSize * 0.75 / 2) - (pieSize * 0.25 / 2), y: (pieSize * 0.75 / 2) - (pieSize * 0.25 / 2)), size: CGSize(width: pieSize * 0.25, height: pieSize * 0.25)))
    playButtonGraphic.addSubview(triangle)
    playButtonGraphic.backgroundColor = UIColor.clear
    playButton.addSubview(playButtonGraphic)
    playButton.isHidden = true
    view.addSubview(playButton)
    
    // tap for pie
    pieTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handlePieTap(gestureRecognizer:)))
    
    // long press for pie
    pieLongPress = UILongPressGestureRecognizer(target: self, action: #selector(PlayController.handlePieLongPress(gestureRecognizer:)))
    
    // pie pan
    piePan = UIPanGestureRecognizer(target: self, action: #selector(PlayController.handlePiePan(gestureRecognizer:)))
    
    // tap for play button
    tg = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleTap(gestureRecognizer:)))
    
    playButton.addGestureRecognizer(tg!)
    
    // nav
    setNavigationItems()
    
    // actions
    setActions()
    disableControls()
    configurePieHolder()
    setMPCommands()
    
    // audio category
    try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [.allowBluetooth, .allowAirPlay, .defaultToSpeaker])
    
    // 
    register(registeredCallback: {
      if self.pies.count > 0 {
        self.createPies(circles: self.circles(), callback: nil)
      } else {
        fetchRandomCircles(completedCallback: { circles, amount in
          self.createPies(circles: circles, callback: nil)
        }, failedCallback: { status in
          handleErrorCode(code: status ?? -1, alertContext: self)
        });
      }
    }, notRegisteredCallback: { status in
    })
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIApplication.shared.beginReceivingRemoteControlEvents()
    self.becomeFirstResponder()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  override var canBecomeFirstResponder : Bool {
    return true
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func createLoadingLabels(_ coveringSize: CGFloat) {
    let labelSize = pieSize / 4
    let yPosition = coveringSize / 2 - labelSize / 2
    
    loadingLabel20 = UILabel(frame: CGRect(origin: CGPoint(x: totalWidth * 0.2 - labelSize / 2, y: yPosition), size: CGSize(width: labelSize, height: labelSize)))
    loadingLabel40 = UILabel(frame: CGRect(origin: CGPoint(x: totalWidth * 0.4 - labelSize / 2, y: yPosition), size: CGSize(width: labelSize, height: labelSize)))
    loadingLabel60 = UILabel(frame: CGRect(origin: CGPoint(x: totalWidth * 0.6 - labelSize / 2, y: yPosition), size: CGSize(width: labelSize, height: labelSize)))
    loadingLabel80 = UILabel(frame: CGRect(origin: CGPoint(x: totalWidth * 0.8 - labelSize / 2, y: yPosition), size: CGSize(width: labelSize, height: labelSize)))
    
    loadingLabel20.textColor = .red
    loadingLabel40.textColor = .white
    loadingLabel60.textColor = .white
    loadingLabel80.textColor = .white
    
    loadingLabel20.textAlignment = .center
    loadingLabel40.textAlignment = .center
    loadingLabel60.textAlignment = .center
    loadingLabel80.textAlignment = .center
    
    loadingLabel20.font = loadingLabel20.font.withSize(pieSize / 4).italic()
    loadingLabel40.font = loadingLabel40.font.withSize(pieSize / 4).italic()
    loadingLabel60.font = loadingLabel60.font.withSize(pieSize / 4).italic()
    loadingLabel80.font = loadingLabel80.font.withSize(pieSize / 4).italic()
    
    loadingLabel20.numberOfLines = 0
    loadingLabel40.numberOfLines = 0
    loadingLabel60.numberOfLines = 0
    loadingLabel80.numberOfLines = 0
    
    loadingLabel20.adjustsFontSizeToFitWidth = true
    loadingLabel40.adjustsFontSizeToFitWidth = true
    loadingLabel60.adjustsFontSizeToFitWidth = true
    loadingLabel80.adjustsFontSizeToFitWidth = true
    
    loadingLabel20.text = "w"
    loadingLabel40.text = "a"
    loadingLabel60.text = "i"
    loadingLabel80.text = "t"

    loadingScreen.addSubview(loadingLabel20)
    loadingScreen.addSubview(loadingLabel40)
    loadingScreen.addSubview(loadingLabel60)
    loadingScreen.addSubview(loadingLabel80)
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
    disableControls()
    
    view.bringSubview(toFront: loadingBackdrop)
    
    self.animateLoadingMessage()
    
    UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
      self.loadingBackdrop.frame.origin.x = 0
    }, completion: { completed in
      
      if showCompleted != nil {
        showCompleted!()
      }
    })
  }
  
  func animateLoadingMessage() {
    var ticks = 0
    
    loadingTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
      switch ticks % 4 {
      case 0:
        self.loadingLabel20.text = "\(ticks / 4 + 1)"
        self.loadingLabel40.text = ""
        self.loadingLabel60.text = ""
        self.loadingLabel80.text = ""
        break
      case 1:
        self.loadingLabel40.text = "2"
        break
      case 2:
        self.loadingLabel60.text = "3"
        break
      case 3:
        self.loadingLabel80.text = "4"
        break
      default:
        self.loadingLabel20.text = "o"
        self.loadingLabel40.text = "h"
        self.loadingLabel60.text = "n"
        self.loadingLabel80.text = "o"
        break
      }
      
      ticks += 1
    })
  }
  
  func hideLoading(_ hideCompleted: (() -> Void)? = nil) {
    UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
      self.loadingBackdrop.frame.origin.x = self.loadingBackdrop.frame.origin.x - self.totalWidth
    }, completion: { completed in
      self.newCircleButton.isEnabled = true
      self.openLinkButton.isEnabled = true
      
      self.loadingTimer.invalidate()
      self.loadingLabel20.text = "w"
      self.loadingLabel40.text = "a"
      self.loadingLabel60.text = "i"
      self.loadingLabel80.text = "t"
      
      self.enableControls()
      
      if hideCompleted != nil {
        hideCompleted!()
      }
    })
  }
  
  func setActions() {
    let actionSize = pieSize / 4
    let x = totalWidth * 0.8 - pieSize / 8
    let y = totalHeight * 0.75
    
    record = UIImageView(image: recordImage)
    record.frame = CGRect(x: x, y: y, width: actionSize, height: actionSize)
    
    let recordTap = UITapGestureRecognizer(target: self, action: #selector(PlayController.handleRecordTap(gestureRecognizer:)))
    record.addGestureRecognizer(recordTap)
    
    view.addSubview(record)
  }
  
  func setNavigationItems() {
    self.navigationItem.title = "Circles of Sound"
    
    let linkButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    linkButton.setImage(linkImage, for: .normal)
    linkButton.addTarget(self, action: #selector(PlayController.openLink(sender:)), for: .touchUpInside)
    
    let recordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    recordButton.setImage(smallRecordImage, for: .normal)
    recordButton.addTarget(self, action: #selector(PlayController.toNewRecording(sender:)), for: .touchUpInside)
    
    newCircleButton = UIBarButtonItem(customView: recordButton)
    openLinkButton = UIBarButtonItem(customView: linkButton)
    
    self.navigationItem.rightBarButtonItem = newCircleButton
    self.navigationItem.leftBarButtonItem = openLinkButton
  }
  
  func configurePieHolder() {
    // for some reason we require left and right swipe definitions? 🤔
    lsg = UISwipeGestureRecognizer(target: self, action: #selector(PlayController.handleSwipe(gestureRecognizer:)))
    rsg = UISwipeGestureRecognizer(target: self, action: #selector(PlayController.handleSwipe(gestureRecognizer:)))
    
    lsg!.direction = .left
    rsg!.direction = .right
    
    piesHolder.addGestureRecognizer(lsg!)
    piesHolder.addGestureRecognizer(rsg!)
    
    pblsg = UISwipeGestureRecognizer(target: self, action: #selector(PlayController.handleSwipe(gestureRecognizer:)))
    pbrsg = UISwipeGestureRecognizer(target: self, action: #selector(PlayController.handleSwipe(gestureRecognizer:)))
    
    pblsg!.direction = .left
    pbrsg!.direction = .right
    
    playButton.addGestureRecognizer(pblsg!)
    playButton.addGestureRecognizer(pbrsg!)
  }
  
  func toNewRecording(sender: AnyObject) {
    let recorder: RecordingController = self.storyboard?.instantiateViewController(withIdentifier: "RecordingController") as! RecordingController
    
    recorder.creationCallback = { data in
      self.showLoading({
        createCircle(data: data, completedCallback: { circles in
          self.positionIndicator.frame.origin.x = self.totalWidth * 0.25 - self.pieSize / 6
          
          self.hideLoading({
            self.createPies(circles: circles, callback: {
              self.scrollToPie(atIndex: 0)
            })
          })
        }, failedCallback: { status in
          self.hideLoading({
            handleErrorCode(code: status ?? -1, alertContext: self)
          })
        })
      })
    }
    
    self.navigationController!.present(recorder, animated: true, completion: {
      if self.audio != nil && self.audio!.isPlaying {
        self.stopPlaying()
      }
      
      self.hideBackdrop()
    })
  }
  
  func circles() -> [Circle] {
    return pies.map({ pie in pie.circle! })
  }
  
  func createPies(circles: [Circle], callback: (() -> Void)?) {
    var offset = (x: piesHolder.center.x - (pieSize / 2) - (CGFloat(currentPieIndex) * (piesHolder.bounds.width / 2)
      ), y: CGFloat(0.0))
    
    piesHolder.subviews.forEach({ $0.removeFromSuperview() })
    pies.removeAll()
    
    for c in circles {
      let p = Pie(circle: c, origin: offset, size: pieSize)
      
      pies.append(p)
      
      let newX = offset.x + (piesHolder.bounds.width / 2)
      let newY = offset.y
      
      offset = (x: newX, y: newY)
    }
    
    renderPies({
      self.loadCircle({
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
    
    if currentPieIndex >= pies.count {
      scrollToPie(atIndex: 0)
    }
    
    if callback != nil {
      callback!()
    }
  }
  
  func enablePieForCircle(circle: Circle) {
    if let pie = pieForCircle(circle: circle) {
      pie.enable()
    }
  }
  
  func disablePieForCircle(circle: Circle) {
    if let pie = pieForCircle(circle: circle) {
      pie.disable()
    }
  }
  
  func pieForCircle(circle: Circle) -> Pie? {
    if let index = pies.index(where: { pie in return pie.circle != nil && pie.circle!.id == circle.id }) {
      return pies[index]
    } else {
      return nil
    }
  }
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    audioTimer.invalidate()
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
  
  func unloadCircle() {
    stopPlaying()
    disableControls()
    self.codeLabel.text = ""
    isPrepared = false
    
    if currentPieIndex < pies.count {
      pies[currentPieIndex].removeGestureRecognizer(pieTap!)
      pies[currentPieIndex].removeGestureRecognizer(piePan!)
      pies[currentPieIndex].removeGestureRecognizer(pieLongPress!)
      pies[currentPieIndex].rotateTo(degreeAngle: 0)
    }
  }
  
  func loadCircle(_ callback: (() -> Void)? = nil) {
    var enabledControls = false
    
    if pies.count - 1 < currentPieIndex {
      enableReloadButton()
      self.setStarState(false)
      self.codeLabel.text = ""
      return
    }
    
    if let circle = pies[currentPieIndex].circle {
      if circle.url == nil || circle.url! == "" {
        self.disableControls()
        self.setStarState(circle.isStarred)
        self.codeLabel.text = circle.code
        self.pies[self.currentPieIndex].disable()
      } else {
        let url = "https://s3.us-east-2.amazonaws.com/tel-serv/" + circle.url!
        
        initAudio(url, callback: {
          self.pies[self.currentPieIndex].addGestureRecognizer(self.pieTap!)
          self.pies[self.currentPieIndex].addGestureRecognizer(self.piePan!)
          self.pies[self.currentPieIndex].addGestureRecognizer(self.pieLongPress!)
          self.pies[self.currentPieIndex].enable()
          self.setPlayProgress()
          self.setStarState(circle.isStarred)
          self.codeLabel.text = circle.code
          self.enableControls()
          self.setNowPlayingInfo(duration: self.audio!.duration)
          
          enabledControls = true
        }, failure: {
          handleErrorCode(code: 437, alertContext: self)
          self.enableReloadButton()
        })
      }
      
      if circle.queuedBuildCount > 0 {
        workingLabel.text = "\(circle.queuedBuildCount)"
        workingLabel.isHidden = false
      } else {
        workingLabel.text = ""
        workingLabel.isHidden = true
      }
    } else {
      self.disableControls()
      self.setStarState(false)
      self.codeLabel.text = ""
      self.pies[self.currentPieIndex].disable()
    }
    
    if !enabledControls {
      enableReloadButton()
    }
    
    if callback != nil {
      callback!()
    }
  }
  
  func setStarState(_ activated: Bool = false) {
    if activated {
      (starButton as! UIImageView).image = goldStarSolidImage
    } else {
      (starButton as! UIImageView).image = goldStarImage
    }
  }
  
  func initAudio(_ url: String, callback: @escaping () -> Void, failure: @escaping () -> Void) {
    if let data = audioCache[url] {
      do {
        try self.audio = AVAudioPlayer(data: data)
        self.audio!.delegate = self
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
  
  func handleSubmitCodeButtonTap() {
    let code = textField.text!
    
    hideBackdrop({
      if code.characters.count == 4 {
        if let pieIndex = self.findPieIndexByCode(code) {
          self.scrollToPie(atIndex: pieIndex)
        } else {
          self.showLoading({
            fetchCircleByCode(code: code, completedCallback: { circle in
              var circles = self.circles()
              
              circles.insert(circle, at: self.currentPieIndex)
              
              self.createPies(circles: circles, callback: {
                self.hideLoading()
              })
            }, failedCallback: { status in
              self.hideLoading({
                handleErrorCode(code: status ?? -1, alertContext: self, extraInfo: code)
              })
            })
          })
        }
      }
    })
  }
  
  func soundForCurrentPlayTime() -> Sound? {
    if audio != nil && pies[currentPieIndex].circle != nil {
      let time = audio!.currentTime
      var segmentTime = 0.0
      
      for sound in pies[currentPieIndex].circle!.sounds {
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
      hideBackdrop({
        self.showLoading({
          let url = "https://s3.us-east-2.amazonaws.com/tel-serv/" + sound.url
          
          Alamofire.request(url).responseData(completionHandler: { dataResponse in
            if let data = dataResponse.data {
              if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                if let filename = sound.url.components(separatedBy: "/").last {
                  let path = dir.appendingPathComponent(filename)
                  
                  do {
                    try data.write(to: path)
                    
                    let av = UIActivityViewController(activityItems: [path], applicationActivities: nil)
                    
                    av.completionWithItemsHandler = { items in
                      self.hideLoading()
                    }
                    
                    self.present(av, animated: true, completion: nil)
                  } catch {
                    NSLog("Error getting data ready to share (single segment): \(error)")
                  }
                }
              }
            }
          })

        })
      })
    }
  }
  
  func handleWholeCircleButtonTap(gestureRecognizer: UITapGestureRecognizer) {
    if audio != nil {
      if let data = audio!.data {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
          if let filename = pies[currentPieIndex].circle!.url!.components(separatedBy: "/").last {
            let path = dir.appendingPathComponent(filename)
            
            do {
              try data.write(to: path)
              
              let av = UIActivityViewController(activityItems: [path], applicationActivities: nil)
              
              av.completionWithItemsHandler = { items in
                self.hideBackdrop()
              }
              
              self.present(av, animated: true, completion: nil)
            } catch {
              NSLog("Error getting data ready to share (full circle): \(error)")
            }
          }
        }
      }
    }
  }
  
  func findPieIndexByCode(_ code: String) -> Int? {
    if let index = circles().index(where: { circle in circle.code == code }) {
      return index
    } else {
      return nil
    }
  }
  
  func scrollToPie(atIndex index: Int) {
    let currentOffset = CGFloat(currentPieIndex) * screenCenterX
    let desiredOffset = CGFloat(index) * screenCenterX
    let scrollAmount = currentOffset - desiredOffset
    
    unloadCircle()
    
    currentPieIndex = index
    
    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
      for view in self.piesHolder.subviews {
        view.frame.origin.x = view.frame.origin.x + scrollAmount
      }
    }, completion: { success in
      self.loadCircle()
    })
  }
  
  func handleBackdropTap(gestureRecognizer: UITapGestureRecognizer) {
    hideBackdrop()
  }
  
  func handleTap(gestureRecognizer: UITapGestureRecognizer) {
    playing ? stopPlaying() : startPlaying()
  }
  
  func handleReloadTap(gestureRecognizer: UITapGestureRecognizer) {
    showLoading({
      if self.audio != nil && self.audio!.isPlaying {
        self.stopPlaying()
      }
      
      reloadCircles(circles: self.circles(), completedCallback: { circles in
        self.hideLoading({
          self.createPies(circles: circles, callback: nil)
        })
      }, failedCallback: { status in
        handleErrorCode(code: status ?? -1, alertContext: self)
      })
    })
  }
  
  func handleRandomizeTap(gestureRecognizer: UITapGestureRecognizer) {
    positionIndicator.frame.origin.x = totalWidth * 0.75 - pieSize / 6
    
    showLoading({
      fetchRandomCircles(completedCallback: { circles, amount in
        self.hideLoading({
          self.createPies(circles: circles, callback: {
            self.scrollToPie(atIndex: 0)
          })
        })
      }, failedCallback: { status in
        self.hideLoading({
          handleErrorCode(code: status ?? -1, alertContext: self)
        })
      });
    })
  }
  
  func handleStarredTap(gestureRecognizer: UITapGestureRecognizer) {
    positionIndicator.frame.origin.x = totalWidth * 0.5 - pieSize / 6
    
    showLoading({
      fetchStarred(completedCallback: { circles in
        self.hideLoading({
          self.createPies(circles: circles, callback: {
            self.scrollToPie(atIndex: 0)
          })
        })
      }, failedCallback: { status in
        self.hideLoading({
          handleErrorCode(code: status ?? -1, alertContext: self)
        })
      })
    })
  }
  
  func handleTokenTap(gestureRecognizer: UITapGestureRecognizer) {
    positionIndicator.frame.origin.x = totalWidth * 0.25 - pieSize / 6
    
    showLoading({
      fetchCirclesForCurrentToken(completedCallback: { circles in
        self.hideLoading({
          self.createPies(circles: circles, callback: {
            self.scrollToPie(atIndex: 0)
          })
        })
      }, failedCallback: { status in
        self.hideLoading({
          handleErrorCode(code: status ?? -1, alertContext: self)
        })
      })
    })
  }
  
  func handleDownloadTap(gestureRecognizer: UITapGestureRecognizer) {
    showDownloadChooser()
  }
  
  func handleStarButtonTap(gestureRecognizer: UITapGestureRecognizer) {
    if pies[currentPieIndex].circle!.url != nil {
      starButton.isUserInteractionEnabled = false
      
      toggleStarred(circle: pies[currentPieIndex].circle!, completedCallback: { circle in
        self.pies[self.currentPieIndex].circle = circle
        self.setStarState(circle.isStarred)
        self.starButton.isUserInteractionEnabled = true
      }, failedCallback: { status in
        self.starButton.isUserInteractionEnabled = true
        handleErrorCode(code: status ?? -1, alertContext: self)
      })
    }
  }
  
  func handlePieTap(gestureRecognizer: UITapGestureRecognizer) {
    let point = gestureRecognizer.location(in: pies[currentPieIndex])
    let time = pies[currentPieIndex].startTimeForPiePieceCoveringPoint(point: point)
    audio!.currentTime = TimeInterval(time)
    setPlayProgress()
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
        let angle = (newPointAngle - startPointAngle) * 180 / .pi
        
        pies[currentPieIndex].rotateBy(degreeAngle: angle)
        adjustAudioProgress(by: -(Double(angle / 360) * audio!.duration))
        
        panStartPoint = newPoint
      }
    }
  }
  
  func handleRecordTap(gestureRecognizer: UITapGestureRecognizer) {
    let recorder: RecordingController = self.storyboard?.instantiateViewController(withIdentifier: "RecordingController") as! RecordingController
    
    recorder.circle = pies[currentPieIndex].circle
    recorder.modalPresentationStyle = .popover
    
    recorder.additionCallback = { data, circle in
      self.showLoading({
        createSound(data: data, circleId: circle.id, completedCallback: { circle in
          var currentCircles = self.circles()
          
          if let index = currentCircles.index(where: { someCircle in someCircle.id == circle.id }) {
            currentCircles[index] = circle
            
            self.hideLoading({
              self.createPies(circles: currentCircles, callback: {
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
    
    self.navigationController!.present(recorder, animated: true, completion: {
      if self.audio != nil && self.audio!.isPlaying {
        self.stopPlaying()
      }
    })
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
    
    self.unloadCircle()
    
    if newX != 0.0 {
      currentPieIndex += pieChange
      
      UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
        for view in self.piesHolder.subviews {
          view.frame.origin.x = view.frame.origin.x + newX
        }
      }, completion: { success in
        self.loadCircle()
      })
    } else {
      let bounceValue = gestureRecognizer.direction == .left ? -(pieSize / 4) : pieSize / 4
      
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
          self.loadCircle()
        })
      })
    }
  }
  
  func enableReloadButton() {
    if pies.count > 0 {
      reloadButton.layer.opacity = 1.0
      reloadButton.isUserInteractionEnabled = true
    }
    
    tokenButton.layer.opacity = 1.0
    starredButton.layer.opacity = 1.0
    randomizeButton.layer.opacity = 1.0
    positionIndicator.layer.opacity = 1.0
    
    tokenButton.isUserInteractionEnabled = true
    starredButton.isUserInteractionEnabled = true
    randomizeButton.isUserInteractionEnabled = true
    positionIndicator.isUserInteractionEnabled = true
    
    openLinkButton.isEnabled = true
    newCircleButton.isEnabled = true
  }
  
  func enableControls() {
    if pies.count > 0 {
      playButton.isHidden = false
      playButton.isUserInteractionEnabled = true
    }
    
    record.layer.opacity = 1.0
    starButton.layer.opacity = 1.0
    tokenButton.layer.opacity = 1.0
    reloadButton.layer.opacity = 1.0
    starredButton.layer.opacity = 1.0
    downloadButton.layer.opacity = 1.0
    randomizeButton.layer.opacity = 1.0
    positionIndicator.layer.opacity = 1.0
    
    record.isUserInteractionEnabled = true
    starButton.isUserInteractionEnabled = true
    tokenButton.isUserInteractionEnabled = true
    reloadButton.isUserInteractionEnabled = true
    starredButton.isUserInteractionEnabled = true
    downloadButton.isUserInteractionEnabled = true
    randomizeButton.isUserInteractionEnabled = true
    positionIndicator.isUserInteractionEnabled = true
    
    openLinkButton.isEnabled = true
    newCircleButton.isEnabled = true
    
    view.bringSubview(toFront: self.playButton)
  }
  
  func disableControls(changeOpacity: Bool = false) {
    record.layer.opacity = 0.5
    starButton.layer.opacity = 0.5
    tokenButton.layer.opacity = 0.5
    reloadButton.layer.opacity = 0.5
    starredButton.layer.opacity = 0.5
    downloadButton.layer.opacity = 0.5
    randomizeButton.layer.opacity = 0.5
    positionIndicator.layer.opacity = 0.5
    
    playButton.isHidden = true
    workingLabel.isHidden = true
    openLinkButton.isEnabled = false
    newCircleButton.isEnabled = false
    record.isUserInteractionEnabled = false
    playButton.isUserInteractionEnabled = false
    starButton.isUserInteractionEnabled = false
    tokenButton.isUserInteractionEnabled = false
    reloadButton.isUserInteractionEnabled = false
    starredButton.isUserInteractionEnabled = false
    downloadButton.isUserInteractionEnabled = false
    randomizeButton.isUserInteractionEnabled = false
    
    view.bringSubview(toFront: self.piesHolder)
  }
  
  func startPlaying() {
    if audio != nil {
      if !isPrepared {
        audio!.prepareToPlay()
        isPrepared = true
      }
      
      try? AVAudioSession.sharedInstance().setActive(true)
      
      playing = true
      setPlayButtonState(to: .playing)
      audio!.play()
      audio!.numberOfLoops = -1
      audioTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(PlayController.setPlayProgress), userInfo: nil, repeats: true)
      
      setNowPlayingInfo(duration: audio!.duration, elapsedPlayback: audio!.currentTime)
    }
  }
  
  func stopPlaying() {
    if audio != nil{
      playing = false
      setPlayButtonState(to: .paused)
      audioTimer.invalidate()
      audio!.pause()
      setNowPlayingInfo(duration: audio!.duration, elapsedPlayback: audio!.currentTime)
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
    
    let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string).replacingOccurrences(of: " ", with: "", options: .literal, range: nil).uppercased()
    
    if string == " " {
      return false
    }
    
    let newLength = text.characters.count + string.characters.count - range.length
    
    if newLength == 4 {
      submitCodeButton.layer.opacity = 1.0
      submitCodeButton.isUserInteractionEnabled = true
      
      return true
    } else {
      if newLength < 4 {
        submitCodeButton.layer.opacity = 0.5
        submitCodeButton.isUserInteractionEnabled = false
        
        return true
      } else if newString.characters.count > 4 {
        let startIndex = newString.startIndex
        let endIndex = newString.index(startIndex, offsetBy: 3)
        let substring = newString[startIndex...endIndex]

        textField.text = substring
        
        submitCodeButton.layer.opacity = 1.0
        submitCodeButton.isUserInteractionEnabled = true
        
        return false
      } else {
        return false
      }
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder();
    
    guard let text = textField.text else { return true }
    
    if text.characters.count == 4 {
      handleSubmitCodeButtonTap()
    } else {
      self.hideBackdrop()
    }
    
    return true;
  }
  
  override func remoteControlReceived(with event: UIEvent?) {
    if event != nil && event!.type == .remoteControl {
      switch event!.subtype {
      case .remoteControlTogglePlayPause:
        if audio != nil {
          if audio!.isPlaying {
            stopPlaying()
          } else {
            startPlaying()
          }
        }
        
        break
      case .remoteControlNextTrack:
        break
      default:
        break
      }
    }
  }
  
  func setMPCommands() {
    let commandCenter = MPRemoteCommandCenter.shared()
    
    commandCenter.playCommand.isEnabled = true
    commandCenter.playCommand.addTarget(handler: { event in
      if self.audio != nil {
        self.startPlaying()
        return .success
      } else {
        return .commandFailed
      }
    })
    
    commandCenter.pauseCommand.addTarget(handler: { event in
      if self.audio != nil {
        self.stopPlaying()
        return .success
      } else {
        return .commandFailed
      }
    })
    
    commandCenter.stopCommand.addTarget(handler: { event in
      if self.audio != nil {
        self.stopPlaying()
        return .success
      } else {
        return .commandFailed
      }
    })
    
    commandCenter.nextTrackCommand.isEnabled = false
    commandCenter.previousTrackCommand.isEnabled = false
  }
  
  func setNowPlayingInfo(duration: TimeInterval, elapsedPlayback: TimeInterval = 0.0) {
    let artwork = MPMediaItemArtwork(boundsSize: cosImage.size, requestHandler: { (cgSize: CGSize) -> UIImage in
      UIGraphicsBeginImageContext(cgSize)
      self.cosImage.draw(in: CGRect(x: 0, y: 0, width: cgSize.width, height: cgSize.height))
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return newImage!
    })
    
    MPNowPlayingInfoCenter.default().nowPlayingInfo = [
      MPMediaItemPropertyTitle: "CoS",
      MPMediaItemPropertyArtwork: artwork,
      MPMediaItemPropertyPlaybackDuration: duration,
      MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsedPlayback
    ]
  }
  
  // yes, this handler is too long and too ugly and too non-DRY
  // i will refactor it later :^)
  
  func handlePieLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state == .began {
      let point = gestureRecognizer.location(in: pies[currentPieIndex])
      let sound = pies[currentPieIndex].soundOfPiePieceCoveringPoint(point: point)
      let circle = pies[currentPieIndex].circle!
      let currentToken = token()
      
      if circle.token == currentToken || sound.token == currentToken {
        if circle.token == currentToken {
          if circle.sounds.count == 1 {
            showOptionsAlert(context: self, message: "Hide this final sound, and the circle, from everyone forever?", yesHandler: { alert in
              self.showLoading({
                hideSound(soundId: sound.id, circleId: circle.id, completedCallback: { circle in
                  if circle == nil {
                    var currentCircles = self.circles()
                    
                    currentCircles.remove(at: self.currentPieIndex)
                    
                    self.hideLoading({
                      self.createPies(circles: currentCircles, callback: {
                        self.setPlayProgress(zero: true)
                      })
                    })
                  } else {
                    var currentCircles = self.circles()
                    
                    if let index = currentCircles.index(where: { someCircle in someCircle.id == circle!.id }) {
                      currentCircles[index] = circle!
                      
                      self.hideLoading({
                        self.createPies(circles: currentCircles, callback: {
                          self.setPlayProgress(zero: true)
                        })
                      })
                    }
                  }
                }, failedCallback: { status in
                  self.hideLoading({
                    handleErrorCode(code: status ?? -1, alertContext: self)
                  })
                })
              })
            })
          } else {
            showMultiOptionsAlert(context: self, message: "Hide this sound, or hide the whole circle, forever?", handlers: [
              (title: "Sound", style: .destructive, handler: { alert in
                self.showLoading({
                  hideSound(soundId: sound.id, circleId: circle.id, completedCallback: { circle in
                    var currentCircles = self.circles()
                    
                    if let index = currentCircles.index(where: { someCircle in someCircle.id == circle!.id }) {
                      currentCircles[index] = circle!
                      
                      self.hideLoading({
                        self.createPies(circles: currentCircles, callback: {
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
              }),
              (title: "Circle", style: .destructive, handler: { alert in
                self.showLoading({
                  hideCircle(circleId: circle.id, completedCallback: {
                    var currentCircles = self.circles()
                    
                    currentCircles.remove(at: self.currentPieIndex)
                    
                    self.hideLoading({
                      self.createPies(circles: currentCircles, callback: {
                        self.setPlayProgress(zero: true)
                      })
                    })
                  }, failedCallback: { status in
                    self.hideLoading({
                      handleErrorCode(code: status ?? -1, alertContext: self)
                    })
                  })
                })
              })
              ])
          }
        } else if sound.token == currentToken {
          let message = circle.sounds.count == 1 ? "Hide this final sound, and the circle, from everyone forever?" : "Hide this sound from everyone forever?"
          
          showOptionsAlert(context: self, message: message, yesHandler: { alert in
            self.showLoading({
              hideSound(soundId: sound.id, circleId: circle.id, completedCallback: { circle in
                if circle == nil {
                  var currentCircles = self.circles()
                  
                  currentCircles.remove(at: self.currentPieIndex)
                  
                  self.hideLoading({
                    self.createPies(circles: currentCircles, callback: {
                      self.setPlayProgress(zero: true)
                    })
                  })
                } else {
                  var currentCircles = self.circles()
                  
                  if let index = currentCircles.index(where: { someCircle in someCircle.id == circle!.id }) {
                    currentCircles[index] = circle!
                    
                    self.hideLoading({
                      self.createPies(circles: currentCircles, callback: {
                        self.setPlayProgress(zero: true)
                      })
                    })
                  }
                }
              }, failedCallback: { status in
                self.hideLoading({
                  handleErrorCode(code: status ?? -1, alertContext: self)
                })
              })
            })
          })
        }
      } else {
        showAlert(context: self, message: "You are not the creator of this circle or this sound so you can't hide it from anyone.")
      }
    }
  }
}
