//
//  ButtonsViewController.swift
//  PickersSample
//
//  Created by Fahim Farook on 1/12/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

class ButtonsViewController: UIViewController {
	@IBOutlet var btnString:StringPickerButton!
	@IBOutlet var btnDate:DatePickerButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		// String picker
		btnString.viewController = self
		btnString.data = ["Red", "Orange", "Yellow", "Green", "Blue", "Indigo", "Violet" ]
		// Date picker
		btnDate.viewController = self			
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
