//
//  FontSwiftPicker.swift
//  SwiftPickers
//
//  Created by Fahim Farook on 30/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

class FontSwiftPicker: BaseSwiftPicker, UIPickerViewDelegate, UIPickerViewDataSource {
	private var selected:UIFont!
	private var done:((FontSwiftPicker, UIFont)->Void)!
	private var cancel:((FontSwiftPicker)->Void)!
	private var data:NSArray!
	private var selection:Int!
	
	// MARK:- Initializers
	convenience init(title:String, selected:UIFont, done:((FontSwiftPicker, UIFont)->Void), cancel:((FontSwiftPicker)->Void)) {
		self.init()
		self.pickerTitle = title
		self.selected = selected
		self.done = done
		self.cancel = cancel
		// Set up data
		data = NSTimeZone.knownTimeZoneNames()
	}
	
	// MARK:- Overrides
	override func configuredPickerView()->UIView? {
		// Set up picker
		let r = CGRect(x:0, y:40, width:szView.width, height:216)
		let picker = UIPickerView(frame:r)
		picker.delegate = self
		picker.dataSource = self
		//		picker.selectRow(selectedIndex, inComponent:0, animated:false)
		let enabled = data.count != 0
		picker.showsSelectionIndicator = enabled
		picker.userInteractionEnabled = enabled
		return picker
	}
	
	override func doneTapped() {
		let fnt = UIFont()
		done(self, fnt)
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
	
	func pickerView(pv:UIPickerView, titleForRow row:Int, forComponent component:Int) -> String! {
		let tz = data[row] as String
		return tz
	}
	
	func pickerView(pv:UIPickerView, didSelectRow row:Int, inComponent component:Int) {
		selection = row
	}
}
