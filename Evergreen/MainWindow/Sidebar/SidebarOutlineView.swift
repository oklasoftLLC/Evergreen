//
//  SidebarOutlineView.swift
//  Evergreen
//
//  Created by Brent Simmons on 11/17/15.
//  Copyright © 2015 Ranchero Software, LLC. All rights reserved.
//

import AppKit
import RSCore

class SidebarOutlineView : NSOutlineView {

	weak var sidebarViewController: SidebarViewController?

	//MARK: NSResponder
	
	override func keyDown(with event: NSEvent) {
		
		guard !event.rs_keyIsModified() else {
			super.keyDown(with: event)
			return
		}
		
		let ch = Int(event.rs_unmodifiedCharacter())
		if ch == NSNotFound {
			super.keyDown(with: event)
			return
		}
		
		var isNavigationKey = false
		var keyHandled = false

		switch(ch) {
			
		case NSRightArrowFunctionKey:
			isNavigationKey = true
			keyHandled = true
			
		case NSDeleteFunctionKey, Int(kDeleteKeyCode):
			keyHandled = true
			sidebarViewController?.delete(event)

		default:
			keyHandled = false
		}

		if isNavigationKey {
			let appInfo = AppInfo()
			appInfo.navigationKey = ch
			NotificationCenter.default.post(name: .AppNavigationKeyPressed, object: self, userInfo: appInfo.userInfo)
			return
		}

		if !keyHandled {
			super.keyDown(with: event)
		}
	}
	
	override func viewWillStartLiveResize() {
		
		if let scrollView = self.enclosingScrollView {
			scrollView.hasVerticalScroller = false
		}
		super.viewWillStartLiveResize()
	}
	
	override func viewDidEndLiveResize() {
		
		if let scrollView = self.enclosingScrollView {
			scrollView.hasVerticalScroller = true
		}
		super.viewDidEndLiveResize()
	}
}
