//
//  ActionSheet.swift
//  SwiftPickers
//
//  Created by Fahim Farook on 29/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

class ActionSheet: UIView {
	let animationDuration = 0.25
	var vwBG = UIView()
	
	private var actWindow:UIWindow!
	private var presented = false
	private var view:UIView!
	
	// MARK:- Init
	convenience init(view:UIView) {
		self.init()
		self.view = view
		// Configure views
		backgroundColor = UIColor(white:0, alpha:0)
		vwBG.backgroundColor = UIColor.whiteColor()
		addSubview(vwBG)
		addSubview(view)
		// Create window
		actWindow = UIWindow(frame:UIScreen.mainScreen().bounds)
		actWindow.windowLevel = UIWindowLevelAlert
		actWindow.backgroundColor = UIColor.clearColor()
		actWindow.rootViewController = ActionSheetVC()
	}
	
	// MARK:- Public Methods
	func dismissWithButtonClick(btnIndex:Int, animated:Bool) {
		let pt = CGPoint(x:view.center.x, y:center.y + CGRectGetHeight(view.frame))
		let dur = animated ? animationDuration : 0.0
		UIView.animateWithDuration(dur, delay:0, options:UIViewAnimationOptions.CurveEaseIn, animations:{
			self.center = pt
			self.backgroundColor = UIColor(white:0, alpha:0)
		}, completion:{(finished) in
			self.destroyWindow()
			self.removeFromSuperview()
		})
	}
	
	func showFromBarButton(btn:UIBarButtonItem, animated:Bool) {
		showInContainerView()
	}
	
	func showInContainerView() {
		// Make sheet window visible and active
		if actWindow.keyWindow {
			actWindow.makeKeyAndVisible()
		}
		actWindow.hidden = false
		// Put the action sheet in the container (it will be presented ASAP)
		actionSheetContainer().actSheet = self
	}
	
	func showActionSheet(animated:Bool) {
		let pt = CGPoint(x:center.x, y:center.y - CGRectGetHeight(view.frame))
		let dur = animated ? animationDuration : 0
		UIView.animateWithDuration(dur, delay:0, options:UIViewAnimationOptions.CurveEaseIn, animations:{
			self.center = pt
			self.backgroundColor = UIColor(white:0, alpha:0.5)
		}, completion:nil)
		presented = true
	}
	
	func setFrameForBounds(b:CGRect) {
		var r = b
		r.size.height += view.bounds.size.height
		frame = r
		r = view.frame
		r.origin.y = b.size.height
		view.frame = r
		view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
		vwBG.frame = view.frame
		vwBG.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
	}
	
	// MARK:- Private Methods
	private func destroyWindow() {
		if actWindow != nil {
			actionSheetContainer().actSheet = nil
			if let w = actWindow {
				w.hidden = true
				if w.keyWindow {
					w.resignFirstResponder()
				}
			}
			actWindow = nil
		}
	}
	
	private func actionSheetContainer()->ActionSheetVC {
		return actWindow.rootViewController as ActionSheetVC
	}
}

class ActionSheetVC: UIViewController {
	var actSheet:ActionSheet? {
		get {
			return self.actSheet
		}
		set {
			if self.actSheet == newValue {
				return
			}
			if let act = self.actSheet {
				if act.presented {
					act.dismissWithButtonClick(0, animated:true)
				}
			}
			self.actSheet = newValue
			presentActionSheet(true)
		}
	}
	
	// MARK:- Overrides
	override func viewWillAppear(animated:Bool) {
		super.viewWillAppear(animated)
		presentActionSheet(true)
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return UIApplication.sharedApplication().statusBarHidden
	}
	
	// MARK:- Private Methods
	private func presentActionSheet(animated:Bool) {
		if let act = actSheet {
			if isViewLoaded() {
				if !act.presented {
					act.setFrameForBounds(view.bounds)
					act.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
					view.addSubview(act)
					act.showActionSheet(animated)
				}
			}
		}
	}
}