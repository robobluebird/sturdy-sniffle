//
//  Network.swift
//  tel
//
//  Created by robobluebird on 10/10/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

func constructUrl(_ tail: String) -> String {
  return "http://localhost:4567/\(tail)"
}

func requestTemporaryToken(completedCallback: @escaping (String) -> Void, failedCallback: @escaping (Int?) -> Void) {
  post(constructUrl("access_tokens/new"), params: nil, completedCallback: { result in
    if let token = result["token"].string {
      completedCallback(token)
    } else {
      failedCallback(nil)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func submitTemporaryToken(token: String, completedCallback: @escaping (String) -> Void, failedCallback: @escaping (Int?) -> Void) {
  post(constructUrl("access_tokens"), params: ["access_token": ["token": token]], completedCallback: { result in
    if let token = result["token"].string {
      completedCallback(token)
    } else {
      failedCallback(nil)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func createChain(data: Data, completedCallback: @escaping (Chain) -> Void, failedCallback: @escaping (Int?) -> Void) {
  formPost(constructUrl("chains"), data: data, completedCallback: { result in
    if result["chain"] != JSON.null {
      completedCallback(Chain(json: result["chain"])!)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func createSound(data: Data, chainId: String, completedCallback: @escaping (Chain) -> Void, failedCallback: @escaping (Int?) -> Void) {
  formPost(constructUrl("chains/\(chainId)/sounds"), data: data, completedCallback: { result in
    if result["chain"] != JSON.null {
      completedCallback(Chain(json: result["chain"])!)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func toggleSound(soundId: String, chainId: String, direction: String, completedCallback: @escaping (Bool) -> Void, failedCallback: @escaping (Int?) -> Void) {
  post(constructUrl("chains/\(chainId)/sounds/\(soundId)/toggle"), params: ["sound": ["direction": direction]], completedCallback: { result in
    completedCallback(result["result"].boolValue)
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func fetchSounds(chainId: String, completedCallback: @escaping ([Sound]) -> Void, failedCallback: @escaping (Int?) -> Void) {
  get(constructUrl("chains/\(chainId)/sounds"), completedCallback: { result in
    if let items = result["sounds"].array {
      var sounds = [Sound]()
      
      for item in items {
        sounds.append(Sound(json: item)!)
      }
      
      completedCallback(sounds)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func fetchChain(_ code: String? = nil, chain: Chain, completedCallback: @escaping (Chain) -> Void, failedCallback: @escaping (Int?) -> Void) {
  var url = "chains/"
  
  if code != nil {
    url.append("by_code/\(code)")
  } else {
    url.append("\(chain.id)")
  }
  
  get(constructUrl(url), completedCallback: { result in
    if let reloadedChain = Chain(json: result["chain"]) {
      completedCallback(reloadedChain)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func reloadChains(chains: [Chain], completedCallback: @escaping ([Chain]) -> Void, failedCallback: @escaping (Int?) -> Void) {
  var url = "chains"
  
  if chains.count > 0 {
    url.append("?chain_ids[]=")
  }
  
  let requestedIds = chains.map({ chain in chain.id }).joined(separator: "&chain_ids[]=")
  
  url.append(requestedIds)
  
  get(constructUrl(url), completedCallback: { result in
    if let items = result["chains"].array {
      var chains = [Chain]()
      
      for item in items {
        chains.append(Chain(json: item)!)
      }
      
      completedCallback(chains)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func fetchChains(_ page: Int?, completedCallback: @escaping ([Chain], Int) -> Void, failedCallback: @escaping (Int?) -> Void) {
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
  }, failedCallback: { status in
    failedCallback(status)
  })
}

// MARK: get and post and form

func get(_ url: String, headers: [String: String]? = nil, completedCallback: @escaping (_ result: JSON) -> Void, failedCallback: @escaping (Int?) -> Void) {
  
  if let token = token() {
   let headers = ["Authorization": "TOKEN Token=\(token)"]
    
    Alamofire.request(url, headers: headers).responseJSON { response in
      if let result = response.result.value {
        completedCallback(JSON(result))
      } else {
        failedCallback(response.response?.statusCode)
      }
    }
  }
}

func post(_ url: String, params: [String: NSDictionary]? = nil, completedCallback: @escaping (_ result: JSON) -> Void, failedCallback: @escaping (Int?) -> Void) {
  var headers = [String: String]()
  
  if let token = token() {
    headers = ["Authorization": "TOKEN Token=\(token)"]
  }
  
  Alamofire.request(url, method: HTTPMethod.post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { response in
    if let result = response.result.value {
      completedCallback(JSON(result))
    } else {
      failedCallback(response.response?.statusCode)
    }
  }
}

func formPost(_ url: String, data: Data, completedCallback: @escaping (_ result: JSON) -> Void, failedCallback: @escaping (Int?) -> Void) {
  if let token = token() {
    Alamofire.upload(
      multipartFormData: { multipartFormData in
        multipartFormData.append(data, withName: "upload", fileName: createFilename("m4a"), mimeType: "audio/m4a")
      },
      to: url,
      method: .post,
      headers: ["Authorization": "TOKEN Token=\(token)"],
      encodingCompletion: { encodingResult in
        switch encodingResult {
        case .success(let upload, _, _):
          upload.responseJSON { response in
            if let result = response.result.value {
              completedCallback(JSON(result))
            } else {
              failedCallback(response.response?.statusCode)
            }
          }
        case .failure(_):
          failedCallback(400)
        }
      }
    )
  }
}
