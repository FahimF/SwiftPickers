//
//  BasePickerButton.swift
//  SwiftPickers
//
//  Created by Fahim Farook on 1/12/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

@IBDesignable class BasePickerButton: UIButton {
	@IBInspectable var pickerTitle:String = ""
	var viewController:UIViewController!
	
	
	private var isIB = false
	private var chevronColor:UIColor!
	
	override var highlighted:Bool {
		willSet {
			if newValue {
				self.chevronColor = tintColor?.colorWithAlphaComponent(0.2)
			} else {
				self.chevronColor = tintColor
			}
			setNeedsDisplay()
		}
	}
	
	// MARK:- Initializers
	required init(coder aDecoder: NSCoder) {
		super.init(coder:aDecoder)
		setup()
	}
	
	override init(frame:CGRect) {
		super.init(frame:frame)
		setup()
	}
	
	// MARK:- Overrides
	override func prepareForInterfaceBuilder() {
		isIB = true
		setup()
	}
	
	override func drawRect(r:CGRect) {
		super.drawRect(r)
		// Draw chevron
		let pt = CGPoint(x:r.size.width - 12, y:(r.size.height * 0.5) - 8)
		let path = UIBezierPath()
		path.moveToPoint(pt)
		path.addLineToPoint(CGPoint(x:pt.x+8, y:pt.y+8))
		path.addLineToPoint(CGPoint(x:pt.x, y:pt.y+8*2))
		path.lineWidth = 2
		chevronColor.set()
		path.stroke()
	}
	
	// MARK:- Public Methods
	func buttonTapped() {
		assert(false, "You cannot use an instance of BasePickerButton. Use a sub-classe instead.")
	}
	
	// MARK:- Private Methods
	func setup() {
		contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
		chevronColor = tintColor
		addTarget(self, action:"buttonTapped", forControlEvents:UIControlEvents.TouchUpInside)
	}
}
