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
	private var selFamily:String!
	private var selFont:String!
	private var families = NSMutableArray()
	private var fonts = NSMutableDictionary()
	
	// MARK:- Initializers
	convenience init(title:String, selected:UIFont, done:((FontSwiftPicker, UIFont)->Void), cancel:((FontSwiftPicker)->Void)) {
		self.init()
		self.pickerTitle = title
		self.selected = selected
		self.done = done
		self.cancel = cancel
		// Set up data
		let data = UIFont.familyNames() as NSArray
		data.enumerateObjectsUsingBlock {(obj, ndx, stop) in
			let fam = obj as String
			// Add family
			self.families.addObject(fam)
			// Get fonts for family
			let fnts = UIFont.fontNamesForFamilyName(fam) as NSArray
			self.fonts[fam] = fnts
		}
		let fam = families.sortedArrayUsingSelector("localizedCaseInsensitiveCompare:") as NSArray
		families = NSMutableArray(array:fam)
		println("Fonts: \(fonts)")
	}
	
	// MARK:- Overrides
	override func configuredPickerView()->UIView? {
		// Set up picker
		let r = CGRect(x:0, y:40, width:szView.width, height:216)
		let picker = UIPickerView(frame:r)
		picker.delegate = self
		picker.dataSource = self
		// Get font family and name from passed in selection
		selFamily = selected.familyName
		selFont = selected.fontName
		let ndxFam = families.indexOfObject(selFamily)
		if ndxFam != NSNotFound {
			if let ndxFont = fonts[selFamily]?.indexOfObject(selFont) {
				picker.selectRow(ndxFam, inComponent:0, animated:false)
				picker.selectRow(ndxFont, inComponent:1, animated:false)
			}
		}
		return picker
	}
	
	override func doneTapped() {
		let sz = selected.fontDescriptor().pointSize
		if let fnt = UIFont(name:selFont, size:sz) {
			done(self, fnt)
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
			return families.count
		} else if component == 1 {
			if let arr = fonts[selFamily] as? NSArray {
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
			lbl.text = families[row] as? String
		} else if component == 1 {
			if let arr = fonts[selFamily] as? NSArray {
				let fnt = arr[row] as? NSString
				// Remove family name
				let fam = (selFamily as NSString).stringByReplacingOccurrencesOfString(" ", withString:"")
				var str = ""
				if let tmp = fnt?.stringByReplacingOccurrencesOfString(fam, withString:"") {
					if tmp.hasPrefix("-") {
						str = (tmp as NSString).substringFromIndex(1)
					} else {
						str = tmp
					}
				}
				if str.isEmpty {
					str = "Regular"
				}
				lbl.text = str
			}
		}
		return lbl
	}
	
	func pickerView(pv:UIPickerView, didSelectRow row:Int, inComponent component:Int) {
		if component == 0 {
			selFamily = families[row] as String
			pv.reloadComponent(1)
			let ndx = pv.selectedRowInComponent(1)
			if let arr = fonts[selFamily] as? NSArray {
				selFont = arr[ndx] as String
			}
		} else if component == 1 {
			if let arr = fonts[selFamily] as? NSArray {
				selFont = arr[row] as String
			}
		}
	}
}
