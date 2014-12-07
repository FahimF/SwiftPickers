//
//  ButtonsViewController.swift
//  PickersSample
//
//  Created by Fahim Farook on 1/12/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

class ButtonsViewController: UIViewController, CustomPickerDelegate {
	@IBOutlet var btnString:StringPickerButton!
	@IBOutlet var btnDateTime:DatePickerButton!
	@IBOutlet var btnDate:DatePickerButton!
	@IBOutlet var btnTime:DatePickerButton!
	@IBOutlet var btnFont:FontPickerButton!
	@IBOutlet var btnTimeZone:TimeZonePickerButton!
	@IBOutlet var btnNumeric:NumericUnitPickerButton!
	@IBOutlet var btnCustom:CustomPickerButton!
	
	private var data = ["String Picker", "Date Picker", "Time Picker", "Date & Time Picker", "Time Zone Picker", "Font Picker", "Custom Picker"]
	
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
		// Font picker
		btnFont.viewController = self
		btnFont.selectedValue = UIFont(name:"Georgia", size:16)!
		// Time Zone picker
		btnTimeZone.viewController = self
		// Numeric Unit picker
		btnNumeric.viewController = self
		let u = UnitDefinition(label:"kg", start:0, end:10)
		btnNumeric.units = [u]
		btnNumeric.selections = [2]
		// Custom picker
		btnCustom.viewController = self
		btnCustom.delegate = self
		if let sel = data.last {
			btnCustom.setTitle(sel)
		}
		btnCustom.picked = {(picker) in
			// Set selection as button title
			let row = picker.selectedRowInComponent(0)
			let sel = self.data[row]
			self.btnCustom.setTitle(sel)
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	// MARK:- Custom Picker Delegates
	func numberOfComponentsInPickerView(pv:UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(pv:UIPickerView, numberOfRowsInComponent component:Int) -> Int {
		return data.count
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
		return data[row]
	}
}
