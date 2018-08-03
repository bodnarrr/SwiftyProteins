//
//  UIViewController+Sharing.swift
//  SwiftyProteins
//
//  Created by Sannacode on 8/3/18.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
	
	func shareScreenshot(_ sender: UIBarButtonItem) {
		UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0)
		self.view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
		let screenshot: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		if let screen = screenshot {
			let activityViewController = UIActivityViewController(
				activityItems: [screen],
				applicationActivities: nil)
			if let popoverPresentationController = activityViewController.popoverPresentationController {
				popoverPresentationController.barButtonItem = sender
			}
			present(activityViewController, animated: true, completion: nil)
		}
	}
}
