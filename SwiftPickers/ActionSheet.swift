//
//  ActionSheet.swift
//  SwiftPickers
//
//  Created by Fahim Farook on 29/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

@objc class ActionSheet: UIView {
	let animationDuration = 0.25
	var vwBG = UIView()
	
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
	}
	
	// MARK:- Public Methods
	func dismissWithButtonClick(btnIndex:Int, animated:Bool) {
		let pt = CGPoint(x:view.center.x, y:center.y + CGRectGetHeight(view.frame))
		let dur = animated ? animationDuration : 0.0
		UIView.animateWithDuration(dur, delay:0, options:UIViewAnimationOptions.CurveEaseIn, animations:{
			self.center = pt
			self.backgroundColor = UIColor(white:0, alpha:0)
		}, completion:{(finished) in
			self.removeFromSuperview()
		})
	}
	
	func showInContainerView() {
		let vc = ActionSheetVC()
		vc.actSheet = self
		let rv = UIApplication.sharedApplication().keyWindow?.subviews.first as UIView
		rv.addSubview(vc.view)
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
}

class ActionSheetVC: UIViewController {
	private var prevAct:ActionSheet? = nil
	var actSheet:ActionSheet? = nil {
		didSet {
			if actSheet == prevAct {
				return
			}
			prevAct = actSheet
			if let act = actSheet {
				if act.presented {
					act.dismissWithButtonClick(0, animated:true)
				}
			}
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