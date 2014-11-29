//
//  BaseSwiftPicker.swift
//  SwiftPickers
//
//  Created by Fahim Farook on 29/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

@objc class BaseSwiftPicker: NSObject, UIPopoverControllerDelegate {
	let kButtonValue = "buttonValue"
	let kButtonTitle = "buttonTitle"
	let kButtonAction = "buttonAction"
	let kButtonTarget = "buttonTarget"
	let isiPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
	let version = (UIDevice.currentDevice().systemVersion as NSString).floatValue
	
	var toolbar = UIToolbar()
	var title:String = ""
	var vwPicker:UIView!
	var szView:CGSize!
	var arrButtons = NSMutableArray()
	var hideCancel:Bool = false
	var presentingRect = CGRectZero
	var titleAttributes:NSDictionary? = nil
	var attributedTitle:NSAttributedString? = nil
	var popoverBGViewClass:AnyClass!
	
	private var btnBar:UIBarButtonItem!
	private var btnDone:UIBarButtonItem!
	private var btnCancel:UIBarButtonItem!
	private var vwContainer:UIView!
	private var actSheet:ActionSheet!
	private var popOver:UIPopoverController!
	
	// MARK:- Initializers
	convenience init(origin:AnyObject) {
		self.init()
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
		// Picker origin
		if origin.isKindOfClass(UIBarButtonItem.classForCoder()) {
			btnBar = origin as UIBarButtonItem
		} else if origin.isKindOfClass(UIView.classForCoder()) {
			vwContainer = origin as UIView
		} else {
			assert(false, "Invalid origin provided to ActionSheetPicker: \(origin)")
		}
		// Picker buttons
		btnDone = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Done, target:self, action:"doneButtonTap")
		btnCancel = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Cancel, target:self, action:"cancelButtonTap")
	}
	
	deinit {
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
	
	// MARK:- Public Methods
	func tapHandler() {
		println("Button tapped")
	}
	
	func configuredPickerView()->UIView? {
		let btn = UIButton.buttonWithType(UIButtonType.System) as UIButton
		btn.frame = CGRect(x:20, y:50, width:100, height:50)
		btn.setTitle("Tap Me", forState:UIControlState.Normal)
		btn.addTarget(self, action:Selector("tapHandler"), forControlEvents:UIControlEvents.TouchUpInside)
//		assert(false, "This is an abstract class, you must use a subclass of BaseSwiftPicker (like StringSwiftPicker or DateSwiftPicker)")
		return btn
	}
	
	func doneButtonTap() {
		doneTapped()
	}
	
	func cancelButtonTap() {
		cancelTapped()
	}
	
	func doneTapped() {
		dismissPicker()
	}
	
	func cancelTapped() {
		dismissPicker()
	}
	
	func customButtonTapped(btn:UIBarButtonItem) {
		
	}
	
	func showPicker() {
		let vwMain = UIView(frame:CGRect(x:0, y:0, width:szView.width, height:260))
		vwMain.backgroundColor = UIColor.whiteColor()
		createToolbar(title)
		vwMain.addSubview(toolbar)
		// Get picker (this is handled by sub-classes)
		vwPicker = configuredPickerView()
		if vwPicker != nil {
			vwMain.addSubview(vwPicker)
		} else {
			assert(false, "Picker view failed to instantiate, perhaps you have invalid component data.")
		}
		presentPickerFor(vwMain)
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
	
	// MARK:- Private Methods
	private func createToolbar(title:String) {
		toolbar.frame = CGRect(x:0, y:0, width:szView.width, height:44)
		toolbar.barStyle = UIBarStyle.Default
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
		if !title.isEmpty {
			// Title label
			let lbl = UILabel(frame:CGRect(x:0, y:0, width:180, height:30))
			lbl.textAlignment = NSTextAlignment.Center
			lbl.backgroundColor = UIColor.clearColor()
			// Set title text (with attributes, if necessary)
			var sz:CGSize
			if titleAttributes != nil {
				lbl.attributedText = NSAttributedString(string:title, attributes:titleAttributes)
				sz = lbl.attributedText.size()
			} else if attributedTitle != nil {
				lbl.attributedText = attributedTitle
				sz = lbl.attributedText.size()
			} else {
				lbl.textColor = UIColor.blackColor()
				let fnt = UIFont.boldSystemFontOfSize(16)
				lbl.font = fnt
				lbl.text = title
				sz = (title as NSString).sizeWithAttributes([NSFontAttributeName:fnt])
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
	
	private func presentPickerFor(view:UIView) {
		presentingRect = view.frame
		if isiPad {
			// Present picker as popover
			let vc = UIViewController()
			vc.view = view
			vc.preferredContentSize = view.frame.size
			popOver = UIPopoverController(contentViewController:vc)
			popOver.delegate = self
			if popoverBGViewClass != nil {
				popOver.popoverBackgroundViewClass = popoverBGViewClass
			}
			presentPopover()
		} else {
			// Present picker as action sheet
			NSNotificationCenter.defaultCenter().addObserver(self, selector:"didRotate:", name:UIApplicationWillChangeStatusBarOrientationNotification, object:nil)
			actSheet = ActionSheet(content:view)
			let rv = UIApplication.sharedApplication().keyWindow?.subviews.first as UIView
			rv.addSubview(actSheet.view)
		}
	}
	
	private func presentPopover() {
		if btnBar != nil {
			popOver.presentPopoverFromBarButtonItem(btnBar, permittedArrowDirections:UIPopoverArrowDirection.Any, animated: true)
			return
		} else if vwContainer != nil {
			popOver.presentPopoverFromRect(vwContainer.bounds, inView:vwContainer, permittedArrowDirections:UIPopoverArrowDirection.Any, animated:true)
			return
		}
		let vw = vwContainer.superview != nil ? vwContainer.superview : vwContainer
		popOver.presentPopoverFromRect(vw.bounds, inView:vw, permittedArrowDirections:UIPopoverArrowDirection.Any, animated:true)
		// Unfortunately, things go to hell whenever you try to present a popover from a table view cell.  These are failsafes.
//		UIView *origin = nil;
//		CGRect presentRect = CGRectZero;
//		@try
//		{
//			origin = (_containerView.superview ? _containerView.superview : _containerView);
//			presentRect = origin.bounds;
//			[popover presentPopoverFromRect:presentRect inView:origin permittedArrowDirections:UIPopoverArrowDirectionAny
//				animated:YES];
//		}
//		@catch (NSException *exception)
//		{
//			origin = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
//			presentRect = CGRectMake(origin.center.x, origin.center.y, 1, 1);
//			[popover presentPopoverFromRect:presentRect inView:origin permittedArrowDirections:UIPopoverArrowDirectionAny
//				animated:YES];
//		}
	}
	
	private func originItem()->AnyObject {
		if btnBar != nil {
			return btnBar
		}
		return vwContainer
	}
	
	private func dismissPicker() {
		if isiPad {
			if popOver != nil && popOver.popoverVisible {
				popOver.dismissPopoverAnimated(true)
			}
		} else {
			if actSheet != nil {
				actSheet.dismissWithButtonClick(0, animated:true)
			}
		}
		actSheet = nil
		popOver = nil
	}
	
	// MARK:- UIPopoverController Delegate Methods
	func popoverControllerDidDismissPopover(povc:UIPopoverController) {
		// Notify target
		cancelTapped()
	}
}
