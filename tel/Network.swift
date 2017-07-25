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

func createCircle(data: Data, completedCallback: @escaping ([Circle]) -> Void, failedCallback: @escaping (Int?) -> Void) {
  formPost(constructUrl("circles"), data: data, completedCallback: { result in
    if result["circles"] != JSON.null {
      if let items = result["circles"].array {
        var circles = [Circle]()
        
        for item in items {
          circles.append(Circle(json: item)!)
        }
        
        completedCallback(circles)
      }
    } else {
      failedCallback(nil)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func createSound(data: Data, circleId: String, completedCallback: @escaping (Circle) -> Void, failedCallback: @escaping (Int?) -> Void) {
  formPost(constructUrl("circles/\(circleId)/sounds"), data: data, completedCallback: { result in
    if result["circle"] != JSON.null {
      completedCallback(Circle(json: result["circle"])!)
    } else {
      failedCallback(nil)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func hideSound(soundId: String, circleId: String, completedCallback: @escaping (Circle?) -> Void, failedCallback: @escaping (Int?) -> Void) {
  post(constructUrl("circles/\(circleId)/sounds/\(soundId)/hide"), params: nil, completedCallback: { result in
    if result["hidden"] != JSON.null {
      if result["hidden"].boolValue == true {
        completedCallback(nil)
      } else {
        failedCallback(nil)
      }
    } else if result["circle"] != JSON.null {
      completedCallback(Circle(json: result["circle"])!)
    } else {
      failedCallback(nil)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func fetchSounds(circleId: String, completedCallback: @escaping ([Sound]) -> Void, failedCallback: @escaping (Int?) -> Void) {
  get(constructUrl("circles/\(circleId)/sounds"), completedCallback: { result in
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

func fetchCircleByCode(code: String, completedCallback: @escaping (Circle) -> Void, failedCallback: @escaping (Int?) -> Void) {
  get(constructUrl("codes/\(code)/circle"), completedCallback: { result in
    if result["circle"] != JSON.null {
      if let circle = Circle(json: result["circle"]) {
        completedCallback(circle)
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

func fetchCircle(circle: Circle, completedCallback: @escaping (Circle) -> Void, failedCallback: @escaping (Int?) -> Void) {
  get(constructUrl("circles/\(circle.id)"), completedCallback: { result in
    if result["circle"] != JSON.null {
      if let reloadedCircle = Circle(json: result["circle"]) {
        completedCallback(reloadedCircle)
      }
    } else {
      failedCallback(392)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func fetchCirclesForCurrentToken(completedCallback: @escaping ([Circle]) -> Void, failedCallback: @escaping (Int?) -> Void) {
  get(constructUrl("created"), completedCallback: { result in
    if result["circles"] != JSON.null {
      if let items = result["circles"].array {
        var circles = [Circle]()
        
        for item in items {
          circles.append(Circle(json: item)!)
        }
        
        completedCallback(circles)
      }
    } else {
      failedCallback(500)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func toggleStarred(circle: Circle, completedCallback: @escaping (Circle) -> Void, failedCallback: @escaping (Int?) -> Void) {
  post(constructUrl("starred"), params: ["circle_id": circle.id], completedCallback: { result in
    if result["circle"] != JSON.null {
      if let circle = Circle(json: result["circle"]) {
        completedCallback(circle)
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

func fetchStarred(completedCallback: @escaping ([Circle]) -> Void, failedCallback: @escaping (Int?) -> Void) {
  get(constructUrl("starred"), completedCallback: { result in
    if let items = result["circles"].array {
      var circles = [Circle]()
      
      for item in items {
        circles.append(Circle(json: item)!)
      }
      
      completedCallback(circles)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}


func reloadCircles(circles: [Circle], completedCallback: @escaping ([Circle]) -> Void, failedCallback: @escaping (Int?) -> Void) {
  var url = "circles"
  
  if circles.count > 0 {
    url.append("?circle_ids[]=")
  }
  
  let requestedIds = circles.map({ circle in circle.id }).joined(separator: "&circle_ids[]=")
  
  url.append(requestedIds)
  
  get(constructUrl(url), completedCallback: { result in
    if let items = result["circles"].array {
      var circles = [Circle]()
      
      for item in items {
        circles.append(Circle(json: item)!)
      }
      
      completedCallback(circles)
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func fetchCircles(_ page: Int?, completedCallback: @escaping ([Circle], Int) -> Void, failedCallback: @escaping (Int?) -> Void) {
  var action = "circles"
  
  if page != nil {
    action = action + "?page=\(page!)"
  }
  
  get(constructUrl(action), completedCallback: { result in
    if let items = result["circles"].array {
      var circles = [Circle]()
      let pages = result["pages"].int
      
      for item in items {
        circles.append(Circle(json: item)!)
      }
      
      completedCallback(circles, (pages ?? 1))
    }
  }, failedCallback: { status in
    failedCallback(status)
  })
}

func fetchRandomCircles(completedCallback: @escaping ([Circle], Int) -> Void, failedCallback: @escaping (Int?) -> Void) {
  get(constructUrl("circles/random"), completedCallback: { result in
    if let items = result["circles"].array {
      var circles = [Circle]()
      let pages = result["pages"].int
      
      for item in items {
        circles.append(Circle(json: item)!)
      }
      
      completedCallback(circles, (pages ?? 1))
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
