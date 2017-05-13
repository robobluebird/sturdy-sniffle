//
//  SoundsController.swift
//  tel
//
//  Created by robobluebird on 10/10/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import MessageUI

//class SoundsController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate, MFMailComposeViewControllerDelegate {
//  var refreshControl: UIRefreshControl?
//  var chain: Chain?
//  var sounds: [Sound] = []
//  var loading: Bool = false
//  var audio: AVAudioPlayer?
//  var timer: Timer?
//  var currentCell: SoundCell?
//  var currentSound: Sound?
//  var loadedSoundData: [String: Data] = [:]
//  
//  @IBOutlet var tableView: UITableView!
//  
//  // MARK: setup
//  
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    
//    configure()
//    
//    doLoading()
//  }
//  
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//  }
//  
//  override func viewDidAppear(_ animated: Bool) {
//    super.viewDidAppear(animated)
//  }
//  
//  override func didReceiveMemoryWarning() {
//    super.didReceiveMemoryWarning()
//  }
//  
//  // MARK: loading
//  
//  func doLoading(_ doOffset: Bool = false) {
//    refreshControl?.beginRefreshing()
//    reloadSounds()
//  }
//  
//  func reloadSounds() {
//    loading = true
//    
//    fetchSounds(chainId: chain!.id, completedCallback: { fetchedSounds in
//      self.sounds = fetchedSounds
//      self.loading = false
//      self.reloadEverything()
//    }, failedCallback: {
//      self.sounds = []
//      self.loading = false
//      self.reloadEverything()
//    })
//  }
//  
//  func reloadEverything() {
//    refreshControl?.endRefreshing()
//    tableView.perform(#selector(UITableView.reloadData), with: nil, afterDelay: 0.3)
//  }
//  
//  // MARK: setup
//  
//  func configure() {
//    configureAudioSession()
//    initRefreshControl()
//    configureTableView()
//  }
//  
//  func configureAudioSession() {
//    let session = AVAudioSession.sharedInstance()
//    
//    do {
//      try session.setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
//      try session.setActive(true)
//      UIApplication.shared.beginReceivingRemoteControlEvents()
//    } catch {
//      NSLog("\(error)")
//    }
//  }
//  
//  func initRefreshControl() {
//    self.refreshControl = UIRefreshControl()
//    self.refreshControl?.tintColor = UIColor.black
//    self.refreshControl?.addTarget(self, action: #selector(SoundsController.doLoading), for: UIControlEvents.valueChanged)
//    self.tableView.addSubview(refreshControl!)
//  }
//  
//  func configureTableView() {
//    self.tableView.delegate = self
//    self.tableView.dataSource = self
//  }
//  
//  // MARK: tableview
//  
//  func numberOfSections(in tableView: UITableView) -> Int {
//    return 1
//  }
//  
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return sounds.count
//  }
//  
//  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//  }
//  
//  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//    return 64.0
//  }
//  
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: "SoundCell", for: indexPath) as! SoundCell
//    
//    let sound = sounds[indexPath.row]
//    
//    cell.sound = sound
//    
//    cell.configure(self.currentSound)
//    
//    if self.currentSound != nil && sound.id == currentSound!.id {
//      currentCell = cell
//      initAudio(sound.url!, cell: cell)
//      setButtonResponses(cell: cell, sound: sound)
//    }
//    
//    return cell
//  }
//  
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    let cell = self.tableView.cellForRow(at: indexPath) as! SoundCell
//    
//    var toReload: [IndexPath] = []
//    
//    let sound = sounds[indexPath.row]
//    
//    if currentSound == nil {
//      currentSound = sound
//    } else {
//      if sound.id == currentSound!.id {
//        unconfigure(cell: cell)
//        currentSound = nil
//      } else {
//        if let oldCell = visibleCellOfSound(sound: currentSound!) {
//          unconfigure(cell: cell)
//          toReload.append(tableView.indexPath(for: oldCell)!)
//        }
//        
//        currentSound = sound
//      }
//    }
//    
//    toReload.append(indexPath)
//    
//    tableView.reloadRows(at: toReload, with: .automatic)
//  }
//  
//  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//    return 0.0
//  }
//  
//  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//    return UIView()
//  }
//  
//  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//    return false
//  }
//  
//  func unconfigure(cell: SoundCell) {
//    if audio != nil {
//      audio!.stop()
//      timer?.invalidate()
//      audio = nil
//    }
//    
//    cell.setPlayButtonToPlay()
//  }
//  
//  func visibleCellOfSound(sound: Sound) -> SoundCell? {
//    return tableView.visibleCells.filter({ cell in cell.tag == sound.id }).first as? SoundCell
//  }
//  
//  func visibleCellOfChain(soundId: Int) -> SoundCell? {
//    return tableView.visibleCells.filter({ cell in cell.tag == soundId }).first as? SoundCell
//  }
//  
//  // MARK: COOL STUFF THAT SHOULDN'T GO HERE!
//  
//  func initAudio(_ url: String, cell: SoundCell) {
//    Alamofire.request(url).responseData(completionHandler: { dataResponse in
//      if dataResponse.data != nil {
//        do {
//          // cell.activityIndicator.startAnimating()
//          
//          try self.audio = AVAudioPlayer(data: dataResponse.data!)
//          self.audio!.delegate = self
//          self.audio!.prepareToPlay()
//          
//          // cell.activityIndicator.stopAnimating()
//        } catch {
//          NSLog("oh deary me. \(self.audio) failed to play in for sound \(cell.sound!.id)")
//        }
//      }
//    })
//  }
//  
//  func setButtonResponses(cell: SoundCell, sound: Sound) {
//    let playGesture = UITapGestureRecognizerWithCell(target: self, action: #selector(SoundsController.playButtonTapped(gesture:)))
//    cell.playButton.addGestureRecognizer(playGesture)
//    
//    let flipGesture = UITapGestureRecognizerWithCell(target: self, action: #selector(SoundsController.includeOrExcludeButtonTapped(gesture:)))
//    cell.includeOrExcludeButton.addGestureRecognizer(flipGesture)
//    
//    let downloadGesture = UITapGestureRecognizerWithCell(target: self, action: #selector(SoundsController.downloadButtonTapped(gesture:)))
//    cell.downloadButton.addGestureRecognizer(downloadGesture)
//    
//    let deleteGesture = UITapGestureRecognizerWithCell(target: self, action: #selector(SoundsController.deleteButtonTapped(gesture:)))
//    cell.deleteButton.addGestureRecognizer(deleteGesture)
//  }
//  
//  func setCurrentCellProgressBarProgress(sender: AnyObject) {
//    currentCell!.setProgressBarProgress(time: Float(audio!.currentTime))
//  }
//  
//  func includeOrExcludeButtonTapped(gesture: UITapGestureRecognizer) {
//  }
//  
//  func downloadButtonTapped(gesture: UITapGestureRecognizer) {
//    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//    
//    let save = UIAlertAction(title: "💾", style: .default) { action in
//      
//    }
//    
//    let email = UIAlertAction(title: "✉️", style: .default) { (action:UIAlertAction) in
//      let mailComposeViewController = self.configuredMailComposeViewController()
//      
//      if MFMailComposeViewController.canSendMail() {
//        self.present(mailComposeViewController, animated: true, completion: nil)
//      }
//    }
//    
//    let cancel = UIAlertAction(title: "cancel", style: .cancel)
//    
//    alertController.addAction(save)
//    alertController.addAction(email)
//    alertController.addAction(cancel)
//    
//    present(alertController, animated: true, completion:nil)
//  }
//  
//  func deleteButtonTapped(gesture: UITapGestureRecognizerWithInt) {
//    if chain != nil && gesture.number != nil {
//      deleteSound(soundId: gesture.number!, chainId: chain!.id, completedCallback: { success in
//        if success {
//          if let index = self.sounds.index(where: { sound in sound.id == gesture.number! } ) {
//            self.sounds.remove(at: index)
//            self.tableView.reloadData()
//          }
//        }
//      }, failedCallback: {
//      })
//    }
//    
//    // func deleteSound(soundId: Int, chainId: Int, completedCallback: @escaping (Bool) -> Void, failedCallback: @escaping () -> Void) {
//  }
//  
//  func playButtonTapped(gesture: UITapGestureRecognizerWithCell) {
//    if audio != nil {
//      if audio!.isPlaying {
//        audio!.stop()
//        timer!.invalidate()
//        currentCell!.setPlayButtonToPlay()
//      } else {
//        audio!.play()
//        
//        if audio!.isPlaying {
//          timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(TelController.setCurrentCellProgressBarProgress(sender:)), userInfo: nil, repeats: true)
//          
//          currentCell!.setPlayButtonToStop()
//        }
//      }
//    }
//  }
//  
//  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//    timer?.invalidate()
//    currentCell?.setPlayButtonToPlay()
//  }
//  
//  func configuredMailComposeViewController() -> MFMailComposeViewController {
//    let mcvc = MFMailComposeViewController()
//    
//    mcvc.mailComposeDelegate = self
//    mcvc.setSubject("\(currentSound!.displayTime()) seconds of audio by \(currentSound!.creator.handle) for chain \(chain!.text)")
//    mcvc.addAttachmentData(audio!.data!, mimeType: "audio/m4a", fileName: "sound.m4a")
//    
//    return mcvc
//  }
//  
//  func exportPath() -> URL? {
//    let fm = FileManager.default
//    let dirs = fm.urls(for: .documentDirectory, in: .userDomainMask)
//    let url = dirs[0]
//    
//    return url.appendingPathComponent("exported.m4a")
//  }
//  
//  // MARK: MFMailComposeViewControllerDelegate Method
//  
//  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//    controller.dismiss(animated: true, completion: nil)
//  }
//}
