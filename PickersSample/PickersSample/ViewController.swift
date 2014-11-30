//
//  ViewController.swift
//  PickersSample
//
//  Created by Fahim Farook on 29/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

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
	}
	
	// MARK:- UITableView Delegates
	override func tableView(tv:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
		switch indexPath.row {
		case 0:
			let data = ["Red", "Blue", "Green", "Yellow"]
			let p = StringSwiftPicker(title:"Colours", data:data, selected:0, done:{(pv, index, value) in
				println("Selected item: \(index) with value: \(value)")
				}, cancel:{(pv) in
					println("Cancelled selection")
			})
			p.showPicker(self)
			
		case 1:
			let p = DateSwiftPicker(title:"Time Picker", mode:UIDatePickerMode.Time, date:NSDate(), done:{(pv, val) in
				println("Selected Date/Value: \(val)")
			}, cancel:{(pv) in
				println("Cancelled selection")
			})
			p.showPicker(self)
			
		case 2:
			let p = DateSwiftPicker(title:"Date Picker", mode:UIDatePickerMode.Date, date:NSDate(), done:{(pv, val) in
				println("Selected Date/Value: \(val)")
				}, cancel:{(pv) in
					println("Cancelled selection")
			})
			p.showPicker(self)
			
		case 3:
			let p = DateSwiftPicker(title:"Date & Time Picker", mode:UIDatePickerMode.DateAndTime, date:NSDate(), done:{(pv, val) in
				println("Selected Date/Value: \(val)")
				}, cancel:{(pv) in
					println("Cancelled selection")
			})
			p.showPicker(self)
			
		case 4:
			let p = DateSwiftPicker(title:"Hour & Minue Picker", mode:UIDatePickerMode.CountDownTimer, date:NSDate(), done:{(pv, val) in
				println("Selected Date/Value: \(val)")
				}, cancel:{(pv) in
					println("Cancelled selection")
			})
			p.showPicker(self)
			
		default:
			println("Unspecified selection. Check your code!")
		}
	}
}

