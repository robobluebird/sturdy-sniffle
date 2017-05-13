//
//  NewChainDismissedProtocol.swift
//  tel
//
//  Created by robobluebird on 10/27/16.
//  Copyright © 2016 bitewolf. All rights reserved.
//

import UIKit

protocol NewChainDelegate {
  func controllerDismissed(chain: Chain?)
  func controllerCancelled()
}
