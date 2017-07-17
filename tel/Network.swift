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

func showIndicator() {
  DispatchQueue.main.async {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }
}

func hideIndicator() {
  DispatchQueue.main.async {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
}

func constructUrl(_ tail: String) -> String {
  return "https://sleepy-atoll-82032.herokuapp.com/\(tail)" // "http://localhost:4567/\(tail)" //
}

func urlRequest(urlString: String) -> URLRequest? {
  if let url = URL(string: urlString) {
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
    
    if let token = token() {
      request.addValue("TOKEN Token=\(token)", forHTTPHeaderField: "Authorization")
      
      return request
    } else {
      return nil
    }
  } else {
    return nil
  }
}

func requestTemporaryToken(completedCallback: @escaping (String) -> Void, failedCallback: @escaping (Int?) -> Void) {
  post(constructUrl("access_tokens/new"), params: nil, completedCallback: { result in
    if let token = result["token"].string {
      completedCallback(token)
    } else {
      failedCallback(500)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func submitTemporaryToken(token: String, completedCallback: @escaping (String) -> Void, failedCallback: @escaping (Int?) -> Void) {
  post(constructUrl("access_tokens"), params: ["token": token], completedCallback: { result in
    if let token = result["token"].string {
      completedCallback(token)
    } else {
      failedCallback(500)
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

func toggleSound(soundId: String, chainId: String, direction: String, completedCallback: @escaping (Chain) -> Void, failedCallback: @escaping (Int?) -> Void) {
  post(constructUrl("chains/\(chainId)/sounds/\(soundId)/toggle"), params: nil, completedCallback: { result in
    if result["chain"] != JSON.null {
      completedCallback(Chain(json: result["chain"])!)
    }
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

func fetchChainByCode(code: String, completedCallback: @escaping (Chain) -> Void, failedCallback: @escaping (Int?) -> Void) {
  get(constructUrl("codes/\(code)/chain"), completedCallback: { result in
    if result["chain"] != JSON.null {
      if let chain = Chain(json: result["chain"]) {
        completedCallback(chain)
      } else {
        failedCallback(500)
      }
    } else {
      failedCallback(681)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func fetchChain(chain: Chain, completedCallback: @escaping (Chain) -> Void, failedCallback: @escaping (Int?) -> Void) {
  get(constructUrl("chains/\(chain.id)"), completedCallback: { result in
    if result["chain"] != JSON.null {
      if let reloadedChain = Chain(json: result["chain"]) {
        completedCallback(reloadedChain)
      }
    } else {
      failedCallback(392)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func toggleStarred(chain: Chain, completedCallback: @escaping (Chain) -> Void, failedCallback: @escaping (Int?) -> Void) {
  post(constructUrl("starred"), params: ["chain_id": chain.id], completedCallback: { result in
    if result["chain"] != JSON.null {
      if let chain = Chain(json: result["chain"]) {
        completedCallback(chain)
      } else {
        failedCallback(500)
      }
    } else {
      failedCallback(681)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func fetchStarred(completedCallback: @escaping ([Chain]) -> Void, failedCallback: @escaping (Int?) -> Void) {
  get(constructUrl("starred"), completedCallback: { result in
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

func fetchRandomChains(completedCallback: @escaping ([Chain], Int) -> Void, failedCallback: @escaping (Int?) -> Void) {
  get(constructUrl("chains/random"), completedCallback: { result in
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
    showIndicator()
    
    let headers = ["Authorization": "TOKEN Token=\(token)"]
    
    Alamofire.request(url, headers: headers).responseJSON { response in
      hideIndicator()
      
      if response.response?.statusCode != 200 {
        failedCallback(response.response?.statusCode)
      } else {
        if let result = response.result.value {
          completedCallback(JSON(result))
        } else {
          failedCallback(500)
        }
      }
    }
  }
}

func post(_ url: String, params: [String: String]? = nil, completedCallback: @escaping (_ result: JSON) -> Void, failedCallback: @escaping (Int?) -> Void) {
  
  var headers = [String: String]()
  
  if let token = token() {
    headers = ["Authorization": "TOKEN Token=\(token)"]
  }
  
  showIndicator()
  
  Alamofire.request(url, method: HTTPMethod.post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { response in
    hideIndicator()
    
    if response.response?.statusCode != 200 {
      failedCallback(response.response?.statusCode)
    } else {
      if let result = response.result.value {
        completedCallback(JSON(result))
      } else {
        failedCallback(500)
      }
    }
  }
}

func formPost(_ url: String, data: Data, completedCallback: @escaping (_ result: JSON) -> Void, failedCallback: @escaping (Int?) -> Void) {
  if let token = token() {
    showIndicator()
    
    Alamofire.upload(
      multipartFormData: { multipartFormData in
        multipartFormData.append(data, withName: "upload", fileName: createFilename("m4a"), mimeType: "audio/m4a")
      },
      to: url,
      method: .post,
      headers: ["Authorization": "TOKEN Token=\(token)"],
      encodingCompletion: { encodingResult in
        hideIndicator()
        
        switch encodingResult {
        case .success(let upload, _, _):
          upload.responseJSON { response in
            if response.response?.statusCode != 200 {
              failedCallback(response.response?.statusCode)
            } else {
              if let result = response.result.value {
                completedCallback(JSON(result))
              } else {
                failedCallback(500)
              }
            }
          }
        case .failure(_):
          failedCallback(500)
        }
      }
    )
  }
}
