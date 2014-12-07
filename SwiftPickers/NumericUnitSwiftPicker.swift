//
//  NumericUnitSwiftPicker.swift
//  SwiftPickers
//
//  Created by Fahim Farook on 30/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

struct UnitDefinition {
	var startValue = 0
	var endValue = 1
	var increment = 1
	var label = "None"
	
	init() {
		
	}
	
	init(label:String, start:Int, end:Int, increment:Int=1) {
		self.label = label
		self.startValue = start
		self.endValue = end
		self.increment = increment
	}
}

class NumericUnitSwiftPicker: BaseSwiftPicker, UIPickerViewDelegate, UIPickerViewDataSource {
	private var units:[UnitDefinition]!
	private var selections:[Int]!
	private var done:((NumericUnitSwiftPicker, [Int])->Void)!
	private var cancel:((NumericUnitSwiftPicker)->Void)!
	private var columns = 0
	private var rowCount = [Int]()
	private var selected = [Int]()
	private var rows = [[String]]()
	
	// MARK:- Initializers
	init(title:String, units:[UnitDefinition], selections:[Int], done:((NumericUnitSwiftPicker, [Int])->Void), cancel:((NumericUnitSwiftPicker)->Void)) {
		assert(units.count == selections.count, "The number of units must match the number of selections passed as parameters")
		super.init()
		self.pickerTitle = title
		self.units = units
		self.selections = selections
		self.done = done
		self.cancel = cancel
		// Calculate picker values
		columns = units.count * 2
		var ndx = 0
		for def in units {
			// Value column
			let cnt = ((def.endValue - def.startValue) / def.increment) + 1
			let sel = selections[ndx]
			rowCount.append(cnt)
			// Generate the values for range
			var arr = [String]()
			var val = 0
			var row = 0
			for i in 0..<cnt {
				if i == 0 {
					val = def.startValue
				} else {
					val = def.startValue + (i * def.increment)
				}
				arr.append("\(val)")
				if val == sel {
					selected.append(row)
				}
				row++
			}
			rows.append(arr)
			// Label column
			rowCount.append(1)
			rows.append([def.label])
			selected.append(0)
			ndx++
		}
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	// MARK:- Overrides
	override func configuredPickerView()->UIView? {
		// Set up picker
		let r = CGRect(x:0, y:40, width:szView.width, height:216)
		let picker = UIPickerView(frame:r)
		picker.delegate = self
		picker.dataSource = self
		// Make initial selections
		var ndx = 0
		for sel in selected {
			picker.selectRow(sel, inComponent:ndx, animated:false)
			ndx++
		}
		let enabled = units.count != 0
		picker.showsSelectionIndicator = enabled
		picker.userInteractionEnabled = enabled
		return picker
	}
	
	override func doneTapped() {
		// Set selections based on selected row for each column
		var ndx = 0
		var col = 0
		for sel in selected {
			// Is this a lable column?
			if ndx % 2 == 0 {
				let vals = rows[ndx]
				selections[col] = (vals[sel] as NSString).integerValue
				col++
			}
			ndx++
		}
		done(self, selections)
		super.doneTapped()
	}
	
	override func cancelTapped() {
		cancel(self)
		super.cancelTapped()
	}
	
	// MARK:- UIPickerView Delegates
	func numberOfComponentsInPickerView(pv:UIPickerView) -> Int {
		return columns
	}
	
	func pickerView(pv:UIPickerView, numberOfRowsInComponent component:Int) -> Int {
		return rowCount[component]
	}
	
	func pickerView(pv:UIPickerView, viewForRow row:Int, forComponent component:Int, reusingView view:UIView!) -> UIView {
		let wd = pv.rowSizeForComponent(component).width
		let sz = CGSize(width:wd, height:32)
		let lbl = getPickerLabel(sz)
		let vals = rows[component]
		lbl.text = vals[row]
		return lbl
	}
	
	func pickerView(pv:UIPickerView, didSelectRow row:Int, inComponent component:Int) {
		selected[component] = row
	}
}
