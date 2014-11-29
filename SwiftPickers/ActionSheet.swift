//
//  ActionSheet.swift
//  SwiftPickers
//
//  Created by Fahim Farook on 29/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

@objc class ActionSheet: UIViewController {
	let animationDuration = 0.25
	private var content:UIView!
	
	// MARK:- Init
	convenience init(content:UIView) {
		self.init()
		self.content = content
		// Configure views
		view.backgroundColor = UIColor(white:0, alpha:0)
		view.addSubview(content)
	}
	
	// MARK:- Overrides
	override func viewWillAppear(animated:Bool) {
		super.viewWillAppear(animated)
		setFrameForBounds(view.bounds)
		content.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
		showActionSheet(animated)
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return UIApplication.sharedApplication().statusBarHidden
	}
	
	// MARK:- Public Methods
	func dismissWithButtonClick(btnIndex:Int, animated:Bool) {
		let pt = CGPoint(x:content.center.x, y:view.center.y + CGRectGetHeight(content.frame))
		let dur = animated ? animationDuration : 0.0
		UIView.animateWithDuration(dur, delay:0, options:UIViewAnimationOptions.CurveEaseIn, animations:{
			self.view.center = pt
			self.view.backgroundColor = UIColor(white:0, alpha:0)
		}, completion:{(finished) in
			self.view.removeFromSuperview()
		})
	}
	
	func showActionSheet(animated:Bool) {
		let pt = CGPoint(x:view.center.x, y:view.center.y - CGRectGetHeight(content.frame))
		let dur = animated ? animationDuration : 0
		UIView.animateWithDuration(dur, delay:0, options:UIViewAnimationOptions.CurveEaseIn, animations:{
			self.view.center = pt
			self.view.backgroundColor = UIColor(white:0, alpha:0.5)
		}, completion:nil)
	}
	
	func setFrameForBounds(b:CGRect) {
		var r = b
		r.size.height += content.bounds.size.height
		view.frame = r
		r = content.frame
		r.origin.y = b.size.height
		content.frame = r
		content.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
	}
}