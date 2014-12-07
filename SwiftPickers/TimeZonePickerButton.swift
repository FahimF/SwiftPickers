//
//  TimeZonePickerButton.swift
//  PickersSample
//
//  Created by Fahim Farook on 7/12/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

class TimeZonePickerButton: BasePickerButton {
	var picked:((NSTimeZone)->Void)!
	
	var selectedValue:NSTimeZone = NSTimeZone.defaultTimeZone() {
		didSet {
			setTitle()
		}
	}
	
	// MARK:- Initializers
	init(vc:UIViewController, title:String, selected:NSTimeZone, picked:((NSTimeZone)->Void)) {
		super.init(frame:CGRectZero)
		self.viewController = vc
		self.pickerTitle = title
		self.selectedValue = selected
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
		let p = TimeZoneSwiftPicker(title:pickerTitle, selected:selectedValue, done:{(pv, value) in
			self.selectedValue = value
			self.setTitle()
			if self.picked != nil {
				self.picked(value)
			}
			}, cancel:{(pv) in
				println("Cancelled selection")
		})
		p.showPicker(viewController)
	}
	
	// MARK:- Private Methods
	private func setTitle() {
		var txt = selectedValue.name
		setTitle(txt, forState:UIControlState.Normal)
	}
}
