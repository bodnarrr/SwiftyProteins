//
//  UIColor+MidColor.swift
//  SwiftyProteins
//
//  Created by Heorhii Shakula on 01.08.2018.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    func coreImageColor() -> CIColor {
        return CIColor(color: self)
    }

    func mid(color: UIColor) -> UIColor {
        let lhs = self.coreImageColor()
        let rhs = color.coreImageColor()
        return UIColor(red: (lhs.red + rhs.red) / 2,
                       green: (lhs.green + rhs.green) / 2,
                       blue: (lhs.blue + rhs.blue) / 2,
                       alpha: (lhs.alpha + rhs.alpha) / 2)
    }
}
