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
	@IBOutlet var btnDateTime:DatePickerButton!
	@IBOutlet var btnDate:DatePickerButton!
	@IBOutlet var btnTime:DatePickerButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		// String picker
		btnString.viewController = self
		btnString.data = ["Red", "Orange", "Yellow", "Green", "Blue", "Indigo", "Violet" ]
		// Date picker
		btnDate.viewController = self
		// Time picker
		btnTime.mode = UIDatePickerMode.Time
		btnTime.viewController = self
		// Date & Time picker
		btnDateTime.mode = UIDatePickerMode.DateAndTime
		btnDateTime.viewController = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
