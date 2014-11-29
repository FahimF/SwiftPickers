//
//  BaseSwiftPicker.swift
//  SwiftPickers
//
//  Created by Fahim Farook on 29/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

class BaseSwiftPicker: NSObject, UIPopoverControllerDelegate {
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
	private var target:AnyObject!
	private var success:Selector!
	private var cancel:Selector!
	private var actSheet:ActionSheet!
	private var popOver:UIPopoverController!
	
	// MARK:- Initializers
	convenience init(target:AnyObject, success:Selector, cancel:Selector, origin:AnyObject) {
		self.init()
		self.target = target
		self.success = success
		self.cancel = cancel
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
		btnDone = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Done, target:self, action:"doneTapped")
		btnCancel = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Cancel, target:self, action:"cancelTapped")
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
		target = nil
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK:- Public Methods
	func doneTapped() {
		notifyTarget(target, success:success, origin:originItem())
		dismissPicker()
	}
	
	func cancelTapped() {
		notifyTarget(target, cancel:cancel, origin:originItem())
		dismissPicker()
	}
	
	func customButtonTapped(btn:UIBarButtonItem) {
		
	}
	
	func showPicker() {
		let vwMain = UIView(frame:CGRect(x:0, y:0, width:szView.width, height:260))
		// iPhone 4 only fix as per: https://github.com/skywinder/ActionSheetPicker-3.0/issues/5
		let model = UIDevice.currentDevice().modelName
		if model.hasPrefix("iPhone3") {
			vwMain.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)
		}
		createToolbar(title)
		vwMain.addSubview(toolbar)
		// The iOS 7 picker has a darkened alpha-only region on the first and last 8 pixels horizontally, but blurs the rest of its background. To make the whole popup appear to be edge-to-edge, we have to add blurring to the remaining left and right edges.
		var r = CGRect(x:0, y:toolbar.frame.origin.y, width:8, height:vwMain.frame.size.height - toolbar.frame.origin.y)
		let ltb = UIToolbar(frame:r)
		r.origin.x = vwMain.frame.size.width - 8
		let rtb = UIToolbar(frame:r)
		ltb.barTintColor = toolbar.barTintColor
		rtb.barTintColor = toolbar.barTintColor
		vwMain.insertSubview(ltb, atIndex:0)
		vwMain.insertSubview(rtb, atIndex:0)
		// Get picker (this is handled by sub-classes)
		vwPicker = configuredPickerView()
		assert(vwPicker != nil, "Picker view failed to instantiate, perhaps you have invalid component data.")
		vwMain.addSubview(vwPicker)
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
	
	func notifyTarget(t:AnyObject, success:Selector, origin:AnyObject) {
		assert(false, "This is an abstract class, you must use a subclass of BaseSwiftPicker (like StringSwiftPicker)")
		if t.respondsToSelector(success) {
			
		}
	}

	func notifyTarget(t:AnyObject, cancel:Selector, origin:AnyObject) {
		if t.respondsToSelector(cancel) {
			assert(false, "This should not be called - if it is, need to figure out how to do performSelector in Swift")
		}
	}
	
	// MARK:- Private Methods
	private func configuredPickerView()->UIView {
		assert(false, "This is an abstract class, you must use a subclass of BaseSwiftPicker (like StringSwiftPicker or DateSwiftPicker)")
	}
	
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
		toolbar.setItems(items, animated:false)
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
			actSheet = ActionSheet(view:view)
			presentActionSheet()
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
	
	private func presentActionSheet() {
		assert(actSheet != nil, "The action sheet can't be nil")
		if btnBar != nil {
			actSheet.showFromBarButton(btnBar, animated:true)
		} else {
			actSheet.showInContainerView()
		}
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
		notifyTarget(target, cancel:cancel, origin:originItem())
	}
	
	// MARK:- Public Methods
}
