//
//  Network.swift
//  tel
//
//  Created by robobluebird on 10/10/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith
import SwiftyJSON

func constructUrl(_ tail: String) -> String {
  return "http://localhost:4567/\(tail)"
}

func createChain(text: String, completedCallback: @escaping (Chain) -> Void, failedCallback: @escaping () -> Void) {
  post(constructUrl("chains"), params: ["chain": ["description": text]], completedCallback: { result in
    let chain = Chain(json: result["chain"])!
    
    completedCallback(chain)
  }, failedCallback: {
    failedCallback()
  })
}

func postSound(data: Data, chainId: String, completedCallback: (Chain?) -> Void, failedCallback: @escaping () -> Void) {
  formPost(constructUrl("chains/\(chainId)/sounds"), elements: [], data: data, completedCallback: { result in
  }, failedCallback: {
    failedCallback()
  })
}

func toggleSound(soundId: String, chainId: String, direction: String, completedCallback: @escaping (Bool) -> Void, failedCallback: @escaping () -> Void) {
  post(constructUrl("chains/\(chainId)/sounds/\(soundId)/toggle"), params: ["sound": ["direction": direction]], completedCallback: { result in
    completedCallback(result["result"].boolValue)
  }, failedCallback: {
    failedCallback()
  })
}

func deleteSound(soundId: String, chainId: String, completedCallback: @escaping (Bool) -> Void, failedCallback: @escaping () -> Void) {
  post(constructUrl("chains/\(chainId)/sounds/\(soundId)/delete"), completedCallback: { result in
    completedCallback(result["result"].boolValue)
  }, failedCallback: {
    failedCallback()
  })
}

func fetchSounds(chainId: String, completedCallback: @escaping ([Sound]) -> Void, failedCallback: @escaping () -> Void) {
  get(constructUrl("chains/\(chainId)/sounds"), completedCallback: { result in
    if let items = result["sounds"].array {
      var sounds = [Sound]()
      
      for item in items {
        sounds.append(Sound(json: item)!)
      }
      
      completedCallback(sounds)
    }
  }, failedCallback: {
    failedCallback()
  })
}

func fetchChains(_ page: Int?, completedCallback: @escaping ([Chain], Int) -> Void, failedCallback: @escaping () -> Void) {
  var action = "chains"
  
  if page != nil {
    action = action + "?page=\(page!)"
  }
  
  get(constructUrl(action), completedCallback: { result in
    if let items = result["chains"].array {
      var chains = [Chain]()
      let pages = result["pages"].int
      
      for item in items {
        chains.append(Chain(json: item)!)
      }
      
      completedCallback(chains, (pages ?? 1))
    }
  }, failedCallback: {
    failedCallback()
  })
}

// MARK: get and post and form

func get(_ url: String, headers: [String: String]? = nil, completedCallback: @escaping (_ result: JSON) -> Void, failedCallback: @escaping () -> Void) {
  
  //  if let key = currentUser()?.apiKey {
  //    let headers = ["Authorization": "Token token=\(key)"]
  Alamofire.request(url, headers: headers).responseJSON { response in
    if let result = response.result.value {
      completedCallback(JSON(result))
    } else {
      failedCallback()
    }
  }
  //  }
}

func post(_ url: String, params: [String: NSDictionary]? = nil, headers: [String: String]? = nil, completedCallback: @escaping (_ result: JSON) -> Void, failedCallback: @escaping () -> Void) {
  
//  if let key = currentUser()?.apiKey {
//    let headers = ["Authorization": "Token token=\(key)"]
  Alamofire.request(url, method: HTTPMethod.post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
    if let result = response.result.value {
      completedCallback(JSON(result))
    } else {
      failedCallback()
    }
  }
//  }
}

func formPost(_ url: String, elements: [String], data: Data, completedCallback: @escaping (_ result: JSON) -> Void, failedCallback: @escaping () -> Void) {
//  if let key = currentUser()?.apiKey {
//    let headers = ["Authorization": "Token token=\(key)"]
    
    Alamofire.upload(
      multipartFormData: { multipartFormData in
        for (_, elem) in elements.enumerated() {
          multipartFormData.append(elem.data(using: .utf8)!, withName: "chain_id")
        }
        
        multipartFormData.append(data, withName: "sound[upload]", fileName: createFilename("m4a"), mimeType: "audio/m4a")
      },
      to: url,
      method: .post,
      headers: nil,
      encodingCompletion: { encodingResult in
        switch encodingResult {
        case .success(let upload, _, _):
          upload.responseJSON { response in
            completedCallback(JSON(response))
          }
        case .failure(_):
          failedCallback()
        }
      }
    )
//  }
}
