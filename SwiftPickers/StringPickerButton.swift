//
//  StringPickerButton.swift
//  PickersSample
//
//  Created by Fahim Farook on 1/12/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

class StringPickerButton: BasePickerButton {
	var selectedValue:String = ""
	var picked:((Int, String)->Void)!

	var data:[String]! {
		didSet {
			if data.count - 1 >= selectedIndex {
				selectedValue = data[selectedIndex] as String
				setTitle(selectedValue, forState:UIControlState.Normal)
			}
		}
	}

	@IBInspectable var selectedIndex:Int = 0 {
		didSet {
			if data != nil && data.count - 1 >= selectedIndex {
				selectedValue = data[selectedIndex]
				setTitle(selectedValue, forState:UIControlState.Normal)
			}
		}
	}
	
	// MARK:- Initializers
	convenience init(vc:UIViewController, title:String, data:[String], selected:Int, picked:((Int, String)->Void)) {
		self.init(frame:CGRectZero)
		self.viewController = vc
		self.data = data
		self.pickerTitle = title
		self.selectedIndex = selected
		self.picked = picked
	}
	
	// MARK:- Overrides
	override func buttonTapped() {
		assert(viewController != nil, "The view controller for the picker has to be set first.")
		assert(data != nil, "The data for the picker has to be set first.")
		let p = StringSwiftPicker(title:pickerTitle, data:data, selected:selectedIndex, done:{(pv, index, value) in
			self.setTitle(value, forState:UIControlState.Normal)
			self.selectedIndex = index
			self.selectedValue = value
			if self.picked != nil {
				self.picked(index, value)
			}
		}, cancel:{(pv) in
				println("Cancelled selection")
		})
		p.showPicker(viewController)
	}
}
