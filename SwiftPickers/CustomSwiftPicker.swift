//
//  CustomSwiftPicker.swift
//  SwiftPickers
//
//  Created by Fahim Farook on 30/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//
//  This is variation of the Objective-C library by skywinder
//  https://github.com/skywinder/ActionSheetPicker-3.0/
//

import UIKit

protocol CustomPickerDelegate: UIPickerViewDelegate, UIPickerViewDataSource {
	
}

class CustomSwiftPicker: BaseSwiftPicker {
	private var delegate:CustomPickerDelegate!
	private var done:((CustomSwiftPicker, UIPickerView)->Void)!
	private var cancel:((CustomSwiftPicker)->Void)!
	private var picker:UIPickerView!
	
	// MARK:- Initializers
	init(title:String, delegate:CustomPickerDelegate, done:((CustomSwiftPicker, UIPickerView)->Void), cancel:((CustomSwiftPicker)->Void)) {
		super.init()
		self.pickerTitle = title
		self.delegate = delegate
		self.done = done
		self.cancel = cancel
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	// MARK:- Overrides
	override func configuredPickerView()->UIView? {
		// Set up picker
		let r = CGRect(x:0, y:40, width:szView.width, height:216)
		picker = UIPickerView(frame:r)
		picker.delegate = delegate
		picker.dataSource = delegate
		return picker
	}
	
	override func doneTapped() {
		done(self, picker)
		super.doneTapped()
	}
	
	override func cancelTapped() {
		cancel(self)
		super.cancelTapped()
	}
}
