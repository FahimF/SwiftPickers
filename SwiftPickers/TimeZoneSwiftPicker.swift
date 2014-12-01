//
//  TimeZoneSwiftPicker.swift
//  SwiftPickers
//
//  Created by Fahim Farook on 30/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//
//  This is variation of the Objective-C library by skywinder
//  https://github.com/skywinder/ActionSheetPicker-3.0/
//

import UIKit

class TimeZoneSwiftPicker: BaseSwiftPicker, UIPickerViewDelegate, UIPickerViewDataSource {
	private var selected:NSTimeZone!
	private var done:((TimeZoneSwiftPicker, NSTimeZone)->Void)!
	private var cancel:((TimeZoneSwiftPicker)->Void)!
	private var selCont:String!
	private var selCity:String!
	private var continents = NSMutableArray()
	private var cities = NSMutableDictionary()
	
	// MARK:- Initializers
	convenience init(title:String, selected:NSTimeZone, done:((TimeZoneSwiftPicker, NSTimeZone)->Void), cancel:((TimeZoneSwiftPicker)->Void)) {
		self.init()
		self.pickerTitle = title
		self.selected = selected
		self.done = done
		self.cancel = cancel
		// Set up data
		let data = NSTimeZone.knownTimeZoneNames() as NSArray
		var buf = NSMutableArray()
		var prev:String!
		data.enumerateObjectsUsingBlock {(obj, ndx, stop) in
			if obj.isKindOfClass(NSString.classForCoder()) {
				let str = obj as NSString
				let arr = str.componentsSeparatedByString("/")
				if arr.count > 1 {
					var cont:String!
					var city:String!
					if arr.count == 2 {
						cont = arr[0] as String
						city = arr[1] as String
					} else if arr.count == 3 {
						cont = arr[0] as String
						city = (arr[1] as String) + "/" + (arr[2] as String)
					}
					if self.continents.indexOfObject(cont) == NSNotFound {
						// New continent
						if prev == nil {
							prev = cont
						} else {
							self.cities[prev] = buf
							buf = NSMutableArray()
							prev = cont
						}
						self.continents.addObject(cont)
						buf.addObject(city)
					} else {
						// Existing continent
						buf.addObject(city)
					}
				}
			}
		}
		// Add the final one
		self.cities[prev] = buf
	}

	// MARK:- Overrides
	override func configuredPickerView()->UIView? {
		// Set up picker
		let r = CGRect(x:0, y:40, width:szView.width, height:216)
		let picker = UIPickerView(frame:r)
		picker.delegate = self
		picker.dataSource = self
		// Get continent and city from passed in selection
		let arr = selected.name.componentsSeparatedByString("/")
		selCont = arr[0] as String
		selCity = arr[1] as String
		let ndxCont = continents.indexOfObject(selCont)
		if ndxCont != NSNotFound {
			if let ndxCity = cities[selCont]?.indexOfObject(selCity) {
				picker.selectRow(ndxCont, inComponent:0, animated:false)
				picker.selectRow(ndxCity, inComponent:1, animated:false)
			}
		}
		return picker
	}
	
	override func doneTapped() {
		let nm = selCont + "/" + selCity
		if let tz = NSTimeZone(name:nm) {
			done(self, tz)
		}
		super.doneTapped()
	}
	
	override func cancelTapped() {
		cancel(self)
		super.cancelTapped()
	}
	
	// MARK:- UIPickerView Delegates
	func numberOfComponentsInPickerView(pv:UIPickerView) -> Int {
		return 2
	}
	
	func pickerView(pv:UIPickerView, numberOfRowsInComponent component:Int) -> Int {
		if component == 0 {
			return continents.count
		} else if component == 1 {
			if let arr = cities[selCont] as? NSArray {
				return arr.count
			}
		}
		return 0
	}
	
	func pickerView(pv:UIPickerView, viewForRow row:Int, forComponent component:Int, reusingView view:UIView!) -> UIView {
		let wd = pv.rowSizeForComponent(component).width
		let sz = CGSize(width:wd, height:32)
		let lbl = getPickerLabel(sz)
		if component == 0 {
			lbl.text = continents[row] as? String
		} else if component == 1 {
			if let arr = cities[selCont] as? NSArray {
				lbl.text = arr[row] as? String
			}
		}
		return lbl
	}
	
	func pickerView(pv:UIPickerView, didSelectRow row:Int, inComponent component:Int) {
		if component == 0 {
			selCont = continents[row] as String
			pv.reloadComponent(1)
			let ndx = pv.selectedRowInComponent(1)
			if let arr = cities[selCont] as? NSArray {
				selCity = arr[ndx] as String
			}
		} else if component == 1 {
			if let arr = cities[selCont] as? NSArray {
				selCity = arr[row] as String
			}
		}
	}
}
