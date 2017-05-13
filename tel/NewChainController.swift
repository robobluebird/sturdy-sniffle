//
//  NewChainController.swift
//  tel
//
//  Created by robobluebird on 10/18/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit

class NewChainController: UIViewController {
  @IBOutlet var chainText: UITextView!
  @IBOutlet var OKButton: UIView!
  @IBOutlet var cancelButton: UIView!
  
  var callback: ((Chain?) -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let ok = InterestingView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), shape: Shape.ok, color: UIColor.green)
    ok.backgroundColor = UIColor.clear
    OKButton.backgroundColor = UIColor.clear
    OKButton.addSubview(ok)
    
    let okCallback = UITapGestureRecognizer(target: self, action: #selector(NewChainController.okButtonTapped(gesture:)))
    OKButton.addGestureRecognizer(okCallback)
    
    let cancel = InterestingView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), shape: Shape.delete, color: UIColor.red)
    cancel.backgroundColor = UIColor.clear
    cancelButton.backgroundColor = UIColor.clear
    cancelButton.addSubview(cancel)
    
    let cancelCallback = UITapGestureRecognizer(target: self, action: #selector(NewChainController.cancelButtonTapped(gesture:)))
    cancelButton.addGestureRecognizer(cancelCallback)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    chainText!.becomeFirstResponder()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func okButtonTapped(gesture: UIGestureRecognizer) {
    if chainText.text.characters.count > 0 && callback != nil {
      createChain(text: chainText.text, completedCallback: { chain in
        self.dismiss(animated: true, completion: {
          self.callback!(chain)
        })
      }, failedCallback: {
        self.dismiss(animated: true, completion: {
          self.callback!(nil)
        })
      })
    }
  }
  
  func cancelButtonTapped(gesture: UIGestureRecognizer) {
    self.dismiss(animated: true, completion: {})
  }
}
