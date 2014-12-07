//
//  DatePickerButton.swift
//  SwiftPickers
//
//  Created by Fahim Farook on 2/12/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

class DatePickerButton: BasePickerButton {
	var maxDate:NSDate!
	var minDate:NSDate!
	var minuteInterval = 1
	var formatString:String = ""
	var locale = NSLocale.currentLocale()
	var calendar = NSCalendar.currentCalendar()
	var timeZone = NSTimeZone.defaultTimeZone()
	var picked:((AnyObject)->Void)!
	
	private var fmt = NSDateFormatter()
	
	var mode:UIDatePickerMode = UIDatePickerMode.Date {
		didSet {
			setDateFormat()
		}
	}

	var selectedValue:AnyObject = NSDate() {
		didSet {
			setTitle()
		}
	}
	
	// MARK:- Initializers
	init(vc:UIViewController, title:String, mode:UIDatePickerMode, selected:AnyObject, picked:((AnyObject)->Void)) {
		super.init(frame:CGRectZero)
		self.viewController = vc
		self.pickerTitle = title
		self.mode = mode
		self.selectedValue = selected
		self.picked = picked
		setTitle()
	}
	
	// MARK:- Overrides
	required init(coder aDecoder: NSCoder) {
		super.init(coder:aDecoder)
		if formatString.isEmpty {
			setDateFormat()
		}
		setTitle()
	}
	
	override func buttonTapped() {
		if viewController == nil {
			assert(false, "The view controller for the picker has to be set first.")
		}
		let p = DateSwiftPicker(title:pickerTitle, mode:mode, selected:selectedValue, done:{(pv, value) in
			self.selectedValue = value
			self.setTitle()
			if self.picked != nil {
				self.picked(value)
			}
			}, cancel:{(pv) in
				println("Cancelled selection")
		})
		p.maxDate = maxDate
		p.minDate = minDate
		p.minuteInterval = minuteInterval
		p.locale = locale
		p.calendar = calendar
		p.timeZone = timeZone
		p.showPicker(viewController)
	}
	
	// MARK:- Private Methods
	private func setTitle() {
		var txt = ""
		if mode == UIDatePickerMode.CountDownTimer {
			let secs = selectedValue as Double
			let hr = Int(secs / 3600)
			let min = Int ((secs % 3600) / 60)
			txt = "\(hr):\(min)"
		} else {
			let dt = selectedValue as NSDate
			txt = fmt.stringFromDate(dt)
		}
		setTitle(txt, forState:UIControlState.Normal)
	}
	
	private func setDateFormat() {
		switch mode {
		case UIDatePickerMode.Time:
			fmt.dateFormat = formatString.isEmpty ? "H:mm" : formatString
			
		case UIDatePickerMode.Date:
			fmt.dateFormat = formatString.isEmpty ? "d MMM yyyy" : formatString
			
		case UIDatePickerMode.DateAndTime:
			fmt.dateFormat = formatString.isEmpty ? "d MMM yyyy H:mm" : formatString
			
		default:
			fmt.dateFormat = formatString.isEmpty ? "d MMM yyyy H:mm" : formatString
		}
		setTitle()
	}
}
