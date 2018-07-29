//
//  TouchIdManager.swift
//  SwiftyProteins
//
//  Created by Andriy BODNAR on 7/29/18.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

class TouchIdManager {
	
	static let shared = TouchIdManager()
	
	private init() {
		authorized = false
	}
	
	var authorized: Bool
	
	func authRequest(_ viewController: UIViewController) {
		
		let context = LAContext()
		let ableToUseTouchId = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
		if ableToUseTouchId {
			print("ABLE")
		} else {
			viewController.showUnsafeModeAlert()
		}
		
	}
}
