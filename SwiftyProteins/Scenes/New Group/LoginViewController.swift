//
//  LoginViewController.swift
//  SwiftyProteins
//
//  Created by Andriy BODNAR on 7/29/18.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
		super.viewDidLoad()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		TouchIdManager.shared.authRequest(self)
	}
	
	@IBAction func iconTapped(_ sender: UITapGestureRecognizer) {
		TouchIdManager.shared.authRequest(self)
	}
	
}
