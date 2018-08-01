//
//  UIColor+CPK.swift
//  SwiftyProteins
//
//  Created by Heorhii Shakula on 01.08.2018.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static let CPKColors = [
        "C" : UIColor.black,
        "O" : UIColor(hexString: "f00000"),
        "H" : UIColor.white,
        "N" : UIColor(hexString: "8f8fff"),
        "S" : UIColor(hexString: "ffc832"),
        "P" : UIColor(hexString: "ffa500"),
        "Cl" : UIColor.green,
        "F" : UIColor.green
    ]

    static func CPK(atomType: String) -> UIColor {
        if let color = CPKColors[atomType] {
            return color
        }
        return UIColor(hexString: "ff1493")
    }
}
