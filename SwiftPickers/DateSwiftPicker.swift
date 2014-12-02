//
//  DateSwiftPicker.swift
//  SwiftPickers
//
//  Created by Fahim Farook on 30/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//
//  This is variation of the Objective-C library by skywinder
//  https://github.com/skywinder/ActionSheetPicker-3.0/
//

import UIKit

class DateSwiftPicker: BaseSwiftPicker {
	var maxDate:NSDate!
	var minDate:NSDate!
	var minuteInterval = 1
	var locale = NSLocale.currentLocale()
	var calendar = NSCalendar.currentCalendar()
	var timeZone = NSTimeZone.defaultTimeZone()
	var countDown = 60.0
	
	private var mode:UIDatePickerMode!
	private var selectedDate:NSDate!
	private var done:((DateSwiftPicker, AnyObject)->Void)!
	private var cancel:((DateSwiftPicker)->Void)!
	
	// MARK:- Initializers
	convenience init(title:String, mode:UIDatePickerMode, selected:AnyObject, done:((DateSwiftPicker, AnyObject)->Void), cancel:((DateSwiftPicker)->Void)) {
		self.init()
		self.pickerTitle = title
		self.mode = mode
		if mode == UIDatePickerMode.CountDownTimer {
			self.countDown = selected as Double
		} else {
			self.selectedDate = selected as NSDate
		}
		self.done = done
		self.cancel = cancel
	}
	
	// MARK:- Overrides
	override func configuredPickerView()->UIView? {
		var r = CGRect(x:0, y:40, width:szView.width, height:216)
		let picker = UIDatePicker(frame:r)
		picker.datePickerMode = mode
		picker.maximumDate = maxDate
		picker.minimumDate = minDate
		picker.minuteInterval = minuteInterval
		picker.calendar = calendar
		picker.timeZone = timeZone
		picker.locale = locale
		// Set the initial value
		if mode == UIDatePickerMode.CountDownTimer {
			picker.countDownDuration = countDown
		} else {
			picker.date = selectedDate
		}
		picker.addTarget(self, action:"pickerValueChanged:", forControlEvents:UIControlEvents.ValueChanged)
		return picker
	}
	
	override func doneTapped() {
		if mode == UIDatePickerMode.CountDownTimer {
			done(self, countDown)
		} else {
			done(self, selectedDate)
		}
		super.doneTapped()
	}
	
	override func cancelTapped() {
		cancel(self)
		super.cancelTapped()
	}
	
	// MARK:- Public Methods
	func pickerValueChanged(picker:UIDatePicker) {
		if mode == UIDatePickerMode.CountDownTimer {
			countDown = picker.countDownDuration
		} else {
			selectedDate = picker.date
		}
	}
}
