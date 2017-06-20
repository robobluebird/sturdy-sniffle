//
//  UIFont.swift
//  tel
//
//  Created by robobluebird on 5/23/17.
//  Copyright © 2017 bitewolf. All rights reserved.
//

import UIKit

extension UIFont {
  func withTraits(_ traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
    return UIFont(descriptor: fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))!, size: 0)
  }
  
  func boldItalic() -> UIFont {
    return withTraits(.traitBold, .traitItalic)
  }
  
  func italic() -> UIFont {
    return withTraits(.traitItalic)
  }
}
