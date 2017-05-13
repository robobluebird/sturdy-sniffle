//
//  TelController.swift
//  tel
//
//  Created by robobluebird on 10/10/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

//class TelController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
//  var chains = [Chain]()
//  var currentChain: Chain?
//  var currentPage = 1
//  var totalPages = 0
//  var loading = false
//  var chainCurrentlyBeingModified: Int?
//  
//  lazy var refreshControl: UIRefreshControl = {
//    let refreshControl = UIRefreshControl()
//    
//    refreshControl.addTarget(self, action: #selector(TelController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
//    
//    return refreshControl
//  }()
//  
//  @IBOutlet var tableView: UITableView!
//  
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    
//    self.tableView.addSubview(self.refreshControl)
//    
//    configure()
//    
//    currentPage = 1
//    
//    handleRefresh(refreshControl: nil)
//  }
//  
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//  }
//  
//  // MARK: loading
//  
//  func configure() {
//    configureAudioSession()
//    configureTableView()
//    setNavigationItems()
//  }
//  
//  func handleRefresh(refreshControl: UIRefreshControl?) {
//    currentPage = 1
//    
//    loadChains(reset: true, coolCallback: {
//      self.tableView.reloadData()
//      refreshControl?.endRefreshing()
//    })
//  }
//  
//  func loadChains(reset: Bool = false, coolCallback: (() -> Void)? = nil) {
//    fetchChains(currentPage, completedCallback: { fetchedChains, totalPages in
//      self.totalPages = totalPages
//      
//      if reset == true {
//        self.chains = fetchedChains
//      } else {
//        self.chains.append(contentsOf: fetchedChains)
//      }
//      
//      self.loading = false
//      
//      if coolCallback != nil {
//        coolCallback!()
//      } else {
//        self.tableView.reloadData()
//      }
//    }, failedCallback: {
//    })
//  }
//  
//  func configureTableView() {
//    self.tableView.delegate = self
//    self.tableView.dataSource = self
//  }
//  
//  func setNavigationItems() {
//    
//    let rect = CGRect(x: 0, y: 0, width: 30, height: 30)
//    let button = UIButton(frame: rect)
//    button.backgroundColor = UIColor.red
//    button.layer.cornerRadius = 15
//    button.addTarget(self, action: #selector(TelController.toNewRecording(sender:)), for: .touchUpInside)
//
//    let recordIt = UIBarButtonItem(customView: button)
//    recordIt.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 30)], for: .normal)
//    
//    self.navigationItem.rightBarButtonItem = recordIt
//  }
//  
//  func toDetail(chainId: String) {
//    let detail: SoundsController = self.storyboard?.instantiateViewController(withIdentifier: "SoundsController") as! SoundsController
//    
//    detail.chain = chains.first(where: { chain in chain.id == chainId })!
//    
//    self.navigationController?.pushViewController(detail, animated: true)
//  }
//  
//  func toNewRecording(sender: AnyObject) {
//    let recorder: RecordingController = self.storyboard?.instantiateViewController(withIdentifier: "RecordingController") as! RecordingController
//    
//    if let tap = sender as? UITapGestureRecognizerWithInt {
//      if tap.number != nil {
//        recorder.chain = chains.first(where: { $0.id == tap.number! })
//      }
//    }
//    
//    recorder.callback = { (data, chain) in
//      if data != nil {
//        if chain == nil {
//          let newChain: NewChainController = self.storyboard?.instantiateViewController(withIdentifier: "NewChainController") as! NewChainController
//          
//          newChain.callback = { chain in
//            if chain != nil {
//              self.processNewThings(data!, chain: chain!)
//            } else {
//            }
//          }
//          
//          self.navigationController!.present(newChain, animated: true, completion: {})
//        } else {
//          self.processNewThings(data!, chain: chain!)
//        }
//      }
//    }
//    
//    self.navigationController!.present(recorder, animated: true, completion: {})
//  }
//  
//  func processNewThings(_ data: Data, chain: Chain) {
//    if let oldIndex = self.chains.index(where: { c in c.id == chain.id}) {
//      self.chains.remove(at: oldIndex)
//    }
//    
//    self.chains.insert(chain, at: 0)
//    
//    self.chainCurrentlyBeingModified = chain.id
//    
//    self.tableView.reloadData()
//    
//    postSound(data: data, chainId: chain.id, completedCallback: self.addedSomethingCallback, failedCallback: {
//      print("kys")
//    })
//  }
//  
//  func addedSomethingCallback(added: Chain?) {
//    DispatchQueue.main.async {
//      if added == nil {
//        showAlert(context: self, message: "We failed to create your sound, sorry about that. The most likely explaination is that your sound was too short or too quiet.")
//        
//        self.chainCurrentlyBeingModified = nil
//        self.tableView.reloadData()
//      } else {
//        if let index = self.chains.index(where: { chain in chain.id == added!.id }) {
//          self.chains[index] = added!
//        }
//      }
//    }
//  }
//  
//  // MARK: audio
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
//  func initAudio(_ url: String, cell: ChainCell) {
//    Alamofire.request(url).responseData(completionHandler: { dataResponse in
//      if dataResponse.data != nil {
//        do {
//          cell.activityIndicator.startAnimating()
//          try self.audio = AVAudioPlayer(data: dataResponse.data!)
//          self.audio!.delegate = self
//          self.audio!.prepareToPlay()
//          self.loadSoundPoints()
//          cell.enablePlayerControls()
//          cell.activityIndicator.stopAnimating()
//          
//          cell.progressBarTappedCallback = { time in
//            if self.audio != nil {
//              self.audio!.currentTime = TimeInterval(time)
//              
//              if !self.audio!.isPlaying {
//                cell.setProgressBarProgress(time: time)
//              }
//            }
//          }
//        } catch {
//          NSLog("oh deary me. \(self.audio) failed to play in for chain \(cell.chain!.id)")
//        }
//      }
//    })
//  }
//  
//  // MARK: tableview
//  
//  func numberOfSections(in tableView: UITableView) -> Int {
//    return 1
//  }
//  
//  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    if currentPage == totalPages || chains.count == 0 {
//      return chains.count
//    }
//    
//    return chains.count + 1
//  }
//  
//  func isLoadingCell(_ indexPath: IndexPath) -> Bool {
//    return (indexPath as NSIndexPath).row == chains.count - 1 && currentPage < totalPages
//  }
//  
//  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//    if isLoadingCell(indexPath) {
//      currentPage += 1
//      loadChains()
//    }
//  }
//  
//  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//    return 100.0
//  }
//  
//  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//    return UITableViewAutomaticDimension
//  }
//  
//  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    if (indexPath as NSIndexPath).row == chains.count {
//      let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
//      
//      cell.activityIndicator.startAnimating()
//      
//      return cell
//    } else {
//      let cell = tableView.dequeueReusableCell(withIdentifier: "ChainCell", for: indexPath) as! ChainCell
//      
//      let chain = chains[indexPath.row]
//      
//      cell.chain = chain
//      
//      cell.configure(self.currentChain)
//      
//      if self.currentChain != nil && chain.id == self.currentChain!.id && chain.url != nil {
//        currentCell = cell
//        self.initAudio(chain.url!, cell: cell)
//        self.setButtonResponses(cell: cell, chain: chain)
//      }
//      
//      return cell
//    }
//  }
//  
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    let cell = self.tableView.cellForRow(at: indexPath) as! ChainCell
//    
//    var toReload: [IndexPath] = []
//    
//    let chain = chains[indexPath.row]
//    
//    if currentChain == nil {
//      currentChain = chain
//    } else {
//      if chain.id == currentChain!.id {
//        unconfigure(cell: cell)
//        currentChain = nil
//      } else {
//        if let oldCell = visibleCellOfChain(chain: currentChain!) {
//          unconfigure(cell: cell)
//          toReload.append(tableView.indexPath(for: oldCell)!)
//        }
//        
//        currentChain = chain
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
//  // MARK: Cell utils
//  
//  func unconfigure(cell: ChainCell) {
//    if audio != nil {
//      audio!.stop()
//      timer?.invalidate()
//      audio = nil
//    }
//    
//    cell.setPlayButtonToPlay()
//  }
//  
//  func visibleCellOfChain(chain: Chain) -> ChainCell? {
//    return tableView.visibleCells.filter({ cell in cell.tag == chain.id }).first as? ChainCell
//  }
//  
//  func visibleCellOfChain(chainId: Int) -> ChainCell? {
//    return tableView.visibleCells.filter({ cell in cell.tag == chainId }).first as? ChainCell
//  }
//  
//  // MARK: stuff that shouldn't go here
//  
//  var audio: AVAudioPlayer?
//  var timer: Timer?
//  var currentCell: ChainCell?
//  var soundPoints: [Float] = []
//  
//  func setButtonResponses(cell: ChainCell, chain: Chain) {
//    let playGesture = UITapGestureRecognizer(target: self, action: #selector(TelController.playButtonTapped))
//    cell.playButton.addGestureRecognizer(playGesture)
//    
//    let recordGesture = UITapGestureRecognizerWithInt(target: self, action: #selector(TelController.toNewRecording(sender:)))
//    recordGesture.number = chain.id
//    cell.recordButton.addGestureRecognizer(recordGesture)
//    
//    let configureGesture = UITapGestureRecognizerWithInt(target: self, action: #selector(TelController.configureButtonTapped(gesture:)))
//    configureGesture.number = chain.id
//    cell.configureButton.addGestureRecognizer(configureGesture)
//  }
//  
//  func loadSoundPoints() {
//    for (_, soundWithTime) in currentChain!.soundsWithTimes.enumerated() {
//      soundPoints.append(soundWithTime.startTime!)
//    }
//  }
//  
//  func setCurrentCellProgressBarProgress(sender: AnyObject) {
//    if audio != nil {
//      currentCell!.setProgressBarProgress(time: Float(audio!.currentTime))
//    }
//  }
//  
//  func configureButtonTapped(gesture: UITapGestureRecognizerWithInt) {
//    if gesture.number != nil {
//      toDetail(chainId: gesture.number!)
//    }
//  }
//
//  func playButtonTapped() {
//    if audio!.isPlaying {
//      timer!.invalidate()
//      audio!.stop()
//      currentCell!.setPlayButtonToPlay()
//    } else {
//      audio!.play()
//      
//      if audio!.isPlaying {
//        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(TelController.setCurrentCellProgressBarProgress(sender:)), userInfo: nil, repeats: true)
//        
//        currentCell!.setPlayButtonToStop()
//      }
//    }
//  }
//}
