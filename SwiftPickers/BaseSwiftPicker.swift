//
//  BaseSwiftPicker.swift
//  SwiftPickers
//
//  Created by Fahim Farook on 29/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//
//  This is variation of the Objective-C library by skywinder
//  https://github.com/skywinder/ActionSheetPicker-3.0/
//

import UIKit

@objc class BaseSwiftPicker: UIViewController {
	let kButtonValue = "buttonValue"
	let kButtonTitle = "buttonTitle"
	let kButtonAction = "buttonAction"
	let kButtonTarget = "buttonTarget"
	let version = (UIDevice.currentDevice().systemVersion as NSString).floatValue
	let animationDuration = 0.25
	let pickerHeight:CGFloat = 320.0
	
	var arrButtons = NSMutableArray()
	var hideCancel:Bool = false
	var titleAttributes:NSDictionary? = nil
	var attributedTitle:NSAttributedString? = nil

	internal var pickerTitle:String = ""
	internal var szView = CGSizeZero

	private var toolbar:UIToolbar!
	private var vwPicker:UIView!
	private var btnDone:UIBarButtonItem!
	private var btnCancel:UIBarButtonItem!
	private var vwContent:UIView!
	private var alTop:NSLayoutConstraint!
	private var isPresenting = false
	
	// MARK:- Initializers
	override init() {
		super.init(nibName:nil, bundle:nil)
		view.backgroundColor = UIColor(white:0, alpha:0)
		// Screen size
		if version >= 8.0 {
			// iOS 8.x or later
			szView = UIScreen.mainScreen().bounds.size
		} else {
			// iOS 7.x
			szView = UIScreen.mainScreen().bounds.size
			if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
				(szView.width, szView.height) = (szView.height, szView.width)
			}
		}
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	// MARK:- Overrides
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		showActionSheet(animated)
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		// Remove picker delegates so that they don't get called later - we have to use a UIView for vwPicker since UIDatePicker is not a subclass of UIPikcerView
		if let pv = vwPicker as? UIPickerView {
			pv.delegate = nil
			pv.dataSource = nil
		}
		if let c = vwPicker as? UIControl {
			c.removeTarget(nil, action:nil, forControlEvents:UIControlEvents.AllEvents)
		}
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return UIApplication.sharedApplication().statusBarHidden
	}
	
	// MARK:- Public Methods
	func configuredPickerView()->UIView? {
		assert(false, "This is an abstract class, you must use a subclass of BaseSwiftPicker (like StringSwiftPicker or DateSwiftPicker)")
		return nil
	}
	
	func doneTapped() {
		dismissPicker()
	}
	
	func cancelTapped() {
		dismissPicker()
	}
	
	func customButtonTapped(btn:UIBarButtonItem) {
		
	}
	
	func showPicker(vc:UIViewController) {
		setupViews()
		setupToolbar()
		// Get picker (this is handled by sub-classes)
		vwPicker = configuredPickerView()
		assert(vwPicker != nil, "Picker view failed to instantiate, perhaps you have invalid component data.")
		vwContent.addSubview(vwPicker)
		isPresenting = true
		vc.addChildViewController(self)
		// Force close keyboard (if visible)
		vc.view.endEditing(true)
		vc.view.addSubview(view)
	}
	
	func didRotate(nt:NSNotification) {
		let curr = UIDevice.currentDevice().orientation
		if let w = UIApplication.sharedApplication().keyWindow {
			let orientations = UIApplication.sharedApplication().supportedInterfaceOrientationsForWindow(w)
			if (orientations & (1 << curr.rawValue)) != 0 {
				dismissPicker()
			}
		}
	}
	
	func getPickerLabel(sz:CGSize)->UILabel {
		let r = CGRect(origin:CGPointZero, size:sz)
		let lbl = UILabel(frame:r)
		lbl.textAlignment = NSTextAlignment.Center
		lbl.minimumScaleFactor = 0.5
		lbl.adjustsFontSizeToFitWidth = true
		lbl.backgroundColor = UIColor.clearColor()
		lbl.font = UIFont.systemFontOfSize(20)
		return lbl
	}
	
	// MARK:- Private Methods
	private func setupViews() {
		// Content view
		if vwContent == nil {
			vwContent = UIView(frame:CGRectZero)
			vwContent.setTranslatesAutoresizingMaskIntoConstraints(false)
			vwContent.backgroundColor = UIColor.whiteColor()
			view.addSubview(vwContent)
			// Content view horizontal layout
			let cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|[vw]|", options:NSLayoutFormatOptions.AlignAllLeft, metrics:nil, views:["vw":vwContent])
			view.addConstraints(cons)
			// Content view top position
			alTop = NSLayoutConstraint(item:vwContent, attribute:NSLayoutAttribute.Top, relatedBy:NSLayoutRelation.Equal, toItem:view, attribute:NSLayoutAttribute.Top, multiplier:0, constant:szView.height)
			view.addConstraint(alTop)
			// Content view height
			let alc = NSLayoutConstraint(item:vwContent, attribute:NSLayoutAttribute.Height, relatedBy:NSLayoutRelation.Equal, toItem:nil, attribute:NSLayoutAttribute.NotAnAttribute, multiplier:0, constant:pickerHeight)
			vwContent.addConstraint(alc)
		}
		// Toolbar
		if toolbar == nil {
			toolbar = UIToolbar(frame:CGRectZero)
			toolbar.setTranslatesAutoresizingMaskIntoConstraints(false)
			toolbar.barStyle = UIBarStyle.Default
			// Create default buttons, if necessary
			if btnDone == nil {
				btnDone = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Done, target:self, action:"doneTapped")
			}
			if btnCancel == nil {
				btnCancel = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Cancel, target:self, action:"cancelTapped")
			}
			vwContent.addSubview(toolbar)
			// Toolbar horizontal layout
			var cons = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tb]|", options:NSLayoutFormatOptions.AlignAllLeft, metrics:nil, views:["tb":toolbar])
			vwContent.addConstraints(cons)
			// Toolbar top position
			cons = NSLayoutConstraint.constraintsWithVisualFormat("V:|[tb(44)]", options:NSLayoutFormatOptions.AlignAllLeft, metrics:nil, views:["tb":toolbar])
			vwContent.addConstraints(cons)
		}
	}
	
	private func setupToolbar() {
		var items = [UIBarButtonItem]()
		// Cancel
		if !hideCancel {
			items.append(btnCancel)
		}
		// Custom Buttons
		var index = 0
		var dic:NSDictionary
		for dic in arrButtons {
			let ttl = dic[kButtonTitle] as String
			let btn = UIBarButtonItem(title:ttl, style:UIBarButtonItemStyle.Plain, target:self, action:"customButtonTapped:")
			btn.tag = index
			items.append(btn)
			index++
		}
		// Spacer
		let spc = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.FlexibleSpace, target:nil, action:nil)
		items.append(spc)
		// Title
		if !pickerTitle.isEmpty {
			// Title label
			let lbl = UILabel(frame:CGRect(x:0, y:0, width:180, height:30))
			lbl.textAlignment = NSTextAlignment.Center
			lbl.backgroundColor = UIColor.clearColor()
			// Set title text (with attributes, if necessary)
			var sz:CGSize
			if titleAttributes != nil {
				lbl.attributedText = NSAttributedString(string:pickerTitle, attributes:titleAttributes)
				sz = lbl.attributedText.size()
			} else if attributedTitle != nil {
				lbl.attributedText = attributedTitle
				sz = lbl.attributedText.size()
			} else {
				lbl.textColor = UIColor.blackColor()
				let fnt = UIFont.boldSystemFontOfSize(16)
				lbl.font = fnt
				lbl.text = pickerTitle
				sz = (pickerTitle as NSString).sizeWithAttributes([NSFontAttributeName:fnt])
			}
			if sz.width < 180 {
				lbl.sizeToFit()
			}
			let btn = UIBarButtonItem(customView:lbl)
			items.append(btn)
			// Add another spacer
			items.append(spc)
		}
		// Done Button
		items.append(btnDone)
		toolbar.items = items
	}
	
	private func dismissPicker() {
		dismissWithButtonClick(0, animated:true)
		isPresenting = false
	}
	
	private func showActionSheet(animated:Bool) {
		view.backgroundColor = UIColor(white:0, alpha:0.5)
		alTop.constant = view.frame.size.height - pickerHeight
		let dur = animated ? animationDuration : 0
		UIView.animateWithDuration(dur, delay:0, options:UIViewAnimationOptions.CurveEaseIn, animations:{
			self.view.layoutIfNeeded()
		}, completion:nil)
	}
	
	private func dismissWithButtonClick(btnIndex:Int, animated:Bool) {
		alTop.constant = view.frame.size.height
		let dur = animated ? animationDuration : 0.0
		UIView.animateWithDuration(dur, delay:0, options:UIViewAnimationOptions.CurveEaseIn, animations:{
			self.view.layoutIfNeeded()
			self.view.backgroundColor = UIColor(white:0, alpha:0)
		}, completion:{(finished) in
				self.view.removeFromSuperview()
		})
	}
}
