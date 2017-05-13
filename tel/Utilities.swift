//
//  Utilities.swift
//  tel
//
//  Created by robobluebird on 10/10/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit
import Locksmith
import SwiftyJSON

func randomColor() -> UIColor {
  let randomRed:CGFloat = CGFloat(drand48())
  let randomGreen:CGFloat = CGFloat(drand48())
  let randomBlue:CGFloat = CGFloat(drand48())
  
  return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
}

func apiKey() -> String? {
  if let data = Locksmith.loadDataForUserAccount(userAccount: "tel") {
    if let key = data["key"] as? String {
      return key
    }
  }
  
  return nil
}

func save() -> Bool {
  return false
}

func showAlert(context: UIViewController, title: String = "Error", message: String) {
  let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
  
  let OKAction = UIAlertAction(title: "Cool", style: .default)
  
  alertController.addAction(OKAction)
  
  context.present(alertController, animated: true)
}

func accountName(handle: String) -> String {
  return "gwolm_\(handle)"
}

func createFilename(_ type: String) -> String {
  return "\(Int(Date().timeIntervalSince1970)).\(type)"
}

func currentUser() -> User? {
  if let userData = Locksmith.loadDataForUserAccount(userAccount: "gwolm") {
    if let user = userData["currentUser"] as? User {
      return user
    } else {
      return nil
    }
  } else {
    return User()
  }
}

func hexStringToUIColor(_ hex: String) -> UIColor {
  var cString:String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
  
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
