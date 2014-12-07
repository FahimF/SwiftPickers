//
//  FontPickerButton.swift
//  PickersSample
//
//  Created by Fahim Farook on 7/12/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

class FontPickerButton: BasePickerButton {
	var picked:((UIFont)->Void)!
	
	var selectedValue:UIFont = UIFont(name:"Helvetica", size:12.0)! {
		didSet {
			setTitle()
		}
	}
	
	// MARK:- Initializers
	init(vc:UIViewController, title:String, selected:UIFont, picked:((UIFont)->Void)) {
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
		if viewController == nil {
			assert(false, "The view controller for the picker has to be set first.")
		}
		let p = FontSwiftPicker(title:pickerTitle, selected:selectedValue, done:{(pv, value) in
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
		var txt = selectedValue.fontName
		let sz = selectedValue.fontDescriptor().pointSize
		txt += " \(sz)"
		setTitle(txt, forState:UIControlState.Normal)
	}
}
