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

@objc class BaseSwiftPicker: UIViewController, UIPopoverControllerDelegate {
	let kButtonValue = "buttonValue"
	let kButtonTitle = "buttonTitle"
	let kButtonAction = "buttonAction"
	let kButtonTarget = "buttonTarget"
	let isiPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
	let version = (UIDevice.currentDevice().systemVersion as NSString).floatValue
	let animationDuration = 0.25
	
	var arrButtons = NSMutableArray()
	var hideCancel:Bool = false
	var titleAttributes:NSDictionary? = nil
	var attributedTitle:NSAttributedString? = nil
	var popoverBGViewClass:AnyClass!

	internal var pickerTitle:String = ""
	internal var szView:CGSize!

	private var toolbar:UIToolbar!
	private var vwPicker:UIView!
	private var btnDone:UIBarButtonItem!
	private var btnCancel:UIBarButtonItem!
	private var vwContent:UIView!
	private var popOver:UIPopoverController!
	private var isPresenting = false
	
	// MARK:- Initializers
	override init() {
		super.init()
		// Picker size
		if isiPad {
			szView = CGSize(width:320, height:320)
		} else {
			if version >= 8.0 {
				// iOS 8.x or later
				szView = UIScreen.mainScreen().bounds.size
			} else {
				// iOS 7.x
				let sz = UIScreen.mainScreen().bounds.size
				if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
					szView = sz
				} else {
					szView.width = sz.height
					szView.height = sz.width
				}
			}
		}
		// Content view
		vwContent = UIView(frame:CGRect(x:0, y:szView.height, width:szView.width, height:260))
		vwContent.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
		// Toolbar
		toolbar = UIToolbar(frame:CGRect(x:0, y:0, width:szView.width, height:44))
		toolbar.autoresizingMask = UIViewAutoresizing.FlexibleWidth
		toolbar.barStyle = UIBarStyle.Default
		// Create default buttons, if necessary
		if btnDone == nil {
			btnDone = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Done, target:self, action:"doneTapped")
		}
		if btnCancel == nil {
			btnCancel = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Cancel, target:self, action:"cancelTapped")
		}
		view.backgroundColor = UIColor(white:0, alpha:0)
		vwContent.addSubview(toolbar)
		vwContent.backgroundColor = UIColor.whiteColor()
		view.addSubview(vwContent)
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
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
		setupToolbar()
		// Get picker (this is handled by sub-classes)
		vwPicker = configuredPickerView()
		vwPicker.autoresizingMask = UIViewAutoresizing.FlexibleWidth
		if vwPicker != nil {
			vwContent.addSubview(vwPicker)
		} else {
			assert(false, "Picker view failed to instantiate, perhaps you have invalid component data.")
		}
		isPresenting = true
		vc.addChildViewController(self)
		// Force close keyboard (if visible)
		vc.view.endEditing(true)
		vc.view.addSubview(view)
	}
	
	func showPicker(btn:UIBarButtonItem) {
		setupToolbar()
		// Get picker (this is handled by sub-classes)
		vwPicker = configuredPickerView()
		if vwPicker != nil {
			vwContent.addSubview(vwPicker)
		} else {
			assert(false, "Picker view failed to instantiate, perhaps you have invalid component data.")
		}
		isPresenting = true
		if isiPad {
			// Present picker as popover
			let vc = UIViewController()
			vc.view = vwContent
			vc.preferredContentSize = vwContent.frame.size
			popOver = UIPopoverController(contentViewController:vc)
			popOver.delegate = self
			if popoverBGViewClass != nil {
				popOver.popoverBackgroundViewClass = popoverBGViewClass
			}
			popOver.presentPopoverFromBarButtonItem(btn, permittedArrowDirections:UIPopoverArrowDirection.Any, animated: true)
		} else {
			assert(false, "Can't present from bar button item on non-iPad devices.")
		}
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
		if isiPad {
			if popOver != nil && popOver.popoverVisible {
				popOver.dismissPopoverAnimated(true)
			}
		} else {
			dismissWithButtonClick(0, animated:true)
		}
		isPresenting = false
		popOver = nil
	}
	
	private func showActionSheet(animated:Bool) {
		self.view.backgroundColor = UIColor(white:0, alpha:0.5)
		var r = vwContent.frame
		r.origin.y = view.frame.size.height - r.size.height
		let dur = animated ? animationDuration : 0
		UIView.animateWithDuration(dur, delay:0, options:UIViewAnimationOptions.CurveEaseIn, animations:{
			self.vwContent.frame = r
			}, completion:nil)
	}
	
	private func dismissWithButtonClick(btnIndex:Int, animated:Bool) {
		var r = vwContent.frame
		r.origin.y = view.frame.size.height
		let dur = animated ? animationDuration : 0.0
		UIView.animateWithDuration(dur, delay:0, options:UIViewAnimationOptions.CurveEaseIn, animations:{
			self.vwContent.frame = r
			self.view.backgroundColor = UIColor(white:0, alpha:0)
			}, completion:{(finished) in
				self.view.removeFromSuperview()
		})
	}
	
	// MARK:- UIPopoverController Delegate Methods
	func popoverControllerDidDismissPopover(povc:UIPopoverController) {
		// Notify target
		cancelTapped()
	}
}
