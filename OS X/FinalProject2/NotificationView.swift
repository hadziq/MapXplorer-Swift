//
//  NotificationView.swift
//  FinalProject2
//
//  Created by Huang Ying-Kai on 2015/3/12.
//  Copyright (c) 2015年 Huang Ying-Kai. All rights reserved.
//

import Cocoa

class NotificationView: NSView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        
        var path = NSBezierPath(roundedRect: dirtyRect, xRadius: 6.0, yRadius: 6.0)
        NSColor.blackColor().set()
        path.fill()
        
    }
    
}
