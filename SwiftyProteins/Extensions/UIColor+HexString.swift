//
//  UIColor+HexString.swift
//  SwiftyProteins
//
//  Created by Heorhii Shakula on 01.08.2018.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {

        var hexInt: UInt32 = 0
        let scanner: Scanner = Scanner(string: hexString)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt32(&hexInt)

        let red = CGFloat((hexInt & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexInt & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexInt & 0xff) >> 0) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
