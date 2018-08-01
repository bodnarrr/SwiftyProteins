//
//  UIViewController+UnsafeAlert.swift
//  SwiftyProteins
//
//  Created by Andriy BODNAR on 7/29/18.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import UIKit

extension UIViewController {
	
	func showUnsafeModeAlert() {
		
		let alert = UIAlertController(title: "TouchID is unavailable on current device!", message: "Warning! Work in unsafe mode!", preferredStyle: .alert)
		let action = UIAlertAction(title: "Ok", style: .default) { [weak self] (action) in
			if TouchIdManager.shared.authorized {
				self?.dismiss(animated: true, completion: nil)
			} else {
				TouchIdManager.shared.authorized = true
				self?.performSegue(withIdentifier: "segueToTableScene", sender: self)
			}
		}
		alert.addAction(action)
		self.present(alert, animated: true, completion: nil)
	}
}
