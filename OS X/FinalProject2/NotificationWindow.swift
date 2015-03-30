//
//  NotificationWindow.swift
//  FinalProject2
//
//  Created by Huang Ying-Kai on 2015/3/12.
//  Copyright (c) 2015年 Huang Ying-Kai. All rights reserved.
//

import Cocoa

class NotificationWindow: NSWindow {
    
    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: NSBackingStoreType.Buffered, defer: flag)
            
            self.alphaValue = 0.75
            self.opaque = false
            self.excludedFromWindowsMenu = false
            self.backgroundColor = NSColor.clearColor()
            
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
