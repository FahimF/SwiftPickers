//
//  NumericUnitPickerButton.swift
//  PickersSample
//
//  Created by Fahim Farook on 7/12/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

class NumericUnitPickerButton: BasePickerButton {
	var units:[UnitDefinition]!
	var picked:(([Int])->Void)!
	
	var selections:[Int]! {
		didSet {
			setTitle()
		}
	}
	
	// MARK:- Initializers
	init(vc:UIViewController, title:String, units:[UnitDefinition], selected:[Int], picked:(([Int])->Void)) {
		super.init(frame:CGRectZero)
		self.viewController = vc
		self.units = units
		self.pickerTitle = title
		self.selections = selected
		self.picked = picked
		setTitle()
	}
	
	// MARK:- Overrides
	required init(coder aDecoder: NSCoder) {
		super.init(coder:aDecoder)
		setTitle()
	}
	
	override func buttonTapped() {
		assert(viewController != nil, "The view controller for the picker has to be set first.")
		assert(units != nil, "The unit definitions for the picker have to be set first.")
		let p = NumericUnitSwiftPicker(title:pickerTitle, units:units, selections:selections, done:{(pv, values) in
			self.selections = values
			self.setTitle()
			if self.picked != nil {
				self.picked(values)
			}
		}, cancel:{(pv) in
				println("Cancelled selection")
		})
		p.showPicker(viewController)
	}
	
	// MARK:- Private Methods
	private func setTitle() {
		var txt = "Numeric Unit Picker (Unset)"
		if selections == nil || units == nil {
			return
		}
		if selections.count > 0 && units.count > 0 {
			txt = ""
			// Get label from selections
			var ndx = 0
			for itm in units {
				let val = selections[ndx]
				if txt.isEmpty {
					txt = "\(val)" + itm.label
				} else {
					txt += ", \(val)" + itm.label
				}
				ndx++
			}
		}
		setTitle(txt, forState:UIControlState.Normal)
	}
}
