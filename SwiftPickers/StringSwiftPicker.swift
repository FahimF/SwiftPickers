//
//  StringSwiftPicker.swift
//  SwiftPickers
//
//  Created by Fahim Farook on 29/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

class StringSwiftPicker: BaseSwiftPicker, UIPickerViewDelegate, UIPickerViewDataSource {
	private var data:NSArray!
	private var selectedIndex:Int!
	private var done:((StringSwiftPicker, Int, String)->Void)!
	private var cancel:((StringSwiftPicker)->Void)!
	
	// MARK:- Initializers
	convenience init(title:String, data:NSArray, selected:Int, done:((StringSwiftPicker, Int, String)->Void), cancel:((StringSwiftPicker)->Void), origin:AnyObject) {
		self.init(origin: origin)
		self.data = data
		self.title = title
		self.selectedIndex = selected
		self.done = done
		self.cancel = cancel
	}
	
	// MARK:- Class Methods
	class func showPicker(title:String, data:NSArray, selected:Int, done:((StringSwiftPicker, Int, String)->Void), cancel:((StringSwiftPicker)->Void), origin:AnyObject)->StringSwiftPicker {
		let ssp = StringSwiftPicker(title:title, data:data, selected:selected, done:done, cancel:cancel, origin:origin)
		ssp.showPicker()
		return ssp
	}
	
	// MARK:- Overrides
	override func configuredPickerView()->UIView? {
		println("Configure picker view")
		// Do not set up a picker if there is no data
		if data == nil {
			return nil
		}
		// Set up picker
		let r = CGRect(x:0, y:40, width:szView.width, height:216)
		let picker = UIPickerView(frame:r)
		picker.delegate = self
		picker.dataSource = self
		picker.selectRow(selectedIndex, inComponent:0, animated:false)
		let enabled = data.count != 0
		picker.showsSelectionIndicator = enabled
		picker.userInteractionEnabled = enabled
		return picker
	}
	
	override func doneTapped() {
		let obj = data[selectedIndex] as String
		done(self, selectedIndex, obj)
		super.doneTapped()
	}
	
	override func cancelTapped() {
		cancel(self)
		super.cancelTapped()
	}
	
	// MARK:- UIPickerView Delegates
	func numberOfComponentsInPickerView(pv:UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(pv:UIPickerView, numberOfRowsInComponent component:Int) -> Int {
		return data.count
	}
	
	func pickerView(pv:UIPickerView, widthForComponent component:Int) -> CGFloat {
		return pv.frame.size.width - 30
	}
	
	func pickerView(pv:UIPickerView, titleForRow row:Int, forComponent component:Int) -> String! {
		if let obj = data[row] as? String {
			return obj
		} else {
			assert(false, "Only string data is supported by this picker type.")
		}
		return nil
	}
	
	func pickerView(pv:UIPickerView, didSelectRow row:Int, inComponent component:Int) {
		selectedIndex = row
	}
}
