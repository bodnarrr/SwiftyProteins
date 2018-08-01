//
//  StartingNavigationViewController.swift
//  SwiftyProteins
//
//  Created by Sannacode on 7/30/18.
//  Copyright © 2018 Andriy BODNAR. All rights reserved.
//

import UIKit

class StartingNavigationViewController: UINavigationController {


	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		performSegue(withIdentifier: "segueToTouchIdScene", sender: self)
	}

}
