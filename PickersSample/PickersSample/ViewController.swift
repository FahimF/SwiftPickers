//
//  ViewController.swift
//  PickersSample
//
//  Created by Fahim Farook on 29/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK:- Actions
	@IBAction func showPicker() {
		let p = BaseSwiftPicker(target:self, success:"pickerPicked", cancel:"pickerCancelled", origin:view)
		p.showPicker()
	}
	
	func pickerPicked() {
		println("Picker picked")
	}
	
	func pickerCancelled() {
		println("Picker cancelled")
	}
}

