//
//  Utilities.swift
//  tel
//
//  Created by robobluebird on 10/10/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit
import Locksmith

func randomColor() -> UIColor {
  let randomRed:CGFloat = CGFloat(drand48())
  let randomGreen:CGFloat = CGFloat(drand48())
  let randomBlue:CGFloat = CGFloat(drand48())
  
  return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
}

func register(registeredCallback: @escaping () -> Void, notRegisteredCallback: @escaping (Int?) -> Void) {
  if token() == nil {
    requestTemporaryToken(completedCallback: { token in
      submitTemporaryToken(token: token, completedCallback: { token in
        do {
          try Locksmith.saveData(data: ["token": token], forUserAccount: "tel")
          
          registeredCallback()
        } catch {
          notRegisteredCallback(nil)
        }
      }, failedCallback: { status in
        notRegisteredCallback(status)
      })
    }, failedCallback: { status in
      notRegisteredCallback(status)
    })
  } else {
    registeredCallback()
  }
}

func token() -> String? {
  if let data = Locksmith.loadDataForUserAccount(userAccount: "tel") {
    if let token = data["token"] as? String {
      return token
    }
  }
  
  return nil
}

func save() -> Bool {
  return false
}

func showAlert(context: UIViewController, title: String = "Error", message: String) {
  let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
  
  let OKAction = UIAlertAction(title: "cool", style: .default)
  
  alertController.addAction(OKAction)
  
  context.present(alertController, animated: true)
}

func createFilename(_ type: String) -> String {
  return "\(Int(Date().timeIntervalSince1970)).\(type)"
}

func hexStringToUIColor(_ hex: String?) -> UIColor? {
  if hex == nil {
    return nil
  }
  
  var cString:String = hex!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
  
  if (cString.hasPrefix("#")) {
    cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 1))
  }
  
  if ((cString.characters.count) != 6) {
    return UIColor.gray
  }
  
  var rgbValue:UInt32 = 0
  Scanner(string: cString).scanHexInt32(&rgbValue)
  
  return UIColor(
    red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
    green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
    blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
    alpha: CGFloat(1.0)
  )
}
