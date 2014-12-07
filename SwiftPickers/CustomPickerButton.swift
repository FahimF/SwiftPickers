//
//  CustomPickerButton.swift
//  PickersSample
//
//  Created by Fahim Farook on 7/12/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

class CustomPickerButton: BasePickerButton {
	var picked:((UIPickerView)->Void)!
	var delegate:CustomPickerDelegate!
	
	// MARK:- Initializers
	init(vc:UIViewController, delegate:CustomPickerDelegate, title:String, picked:((UIPickerView)->Void)) {
		super.init(frame:CGRectZero)
		self.viewController = vc
		self.delegate = delegate
		self.pickerTitle = title
		self.picked = picked
		setTitle("Custom Picker")
	}
	
	// MARK:- Overrides
	required init(coder aDecoder: NSCoder) {
		super.init(coder:aDecoder)
		setTitle("Custom Picker")
	}
	
	override func buttonTapped() {
		assert(viewController != nil, "The view controller for the picker has to be set first.")
		assert(delegate != nil, "The delegate for the picker has to be set first.")
		let p = CustomSwiftPicker(title:pickerTitle, delegate:delegate, done:{(pv, picker) in
			if self.picked != nil {
				self.picked(picker)
			}
		}, cancel:{(pv) in
			println("Cancelled selection")
		})
		p.showPicker(viewController)
	}
	
	// MARK:- Public methods
	func setTitle(ttl:String) {
		setTitle(ttl, forState:UIControlState.Normal)
	}
	
}
