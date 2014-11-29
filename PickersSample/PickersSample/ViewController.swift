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
		let p = BaseSwiftPicker(origin:view)
//		let data = ["Red", "Blue", "Green", "Yellow"]
//		let p = StringSwiftPicker(title:"Colours", data:data, selected:0, done:{(pv, index, value) in
//			println("Selected item: \(index) with value: \(value)")
//		}, cancel:{(pv) in
//			println("Cancelled selection")
//		}, origin:view)
		p.showPicker()
	}
	
}

