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
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Logging in with Touch ID") { [weak self] (success, evaluateError) in
				if success {
					if (self?.authorized)! {
						viewController.dismiss(animated: true, completion: nil)
					} else {
						self?.authorized = true
						viewController.performSegue(withIdentifier: "segueToTableScene", sender: self)
					}
				} else {
					print(evaluateError?.localizedDescription)
					if evaluateError?.localizedDescription == "Fallback authentication mechanism selected." {
						context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Enter your password", reply: { (success, error) in
							if success {
								if (self?.authorized)! {
									viewController.dismiss(animated: true, completion: nil)
								} else {
									self?.authorized = true
									viewController.performSegue(withIdentifier: "segueToTableScene", sender: self)
								}
							}
						})
					}
				}
			}
			
		} else {
			viewController.showUnsafeModeAlert()
		}
		
	}
}
