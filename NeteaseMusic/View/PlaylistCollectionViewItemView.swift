//
//  PlaylistCollectionViewItemView.swift
//  NeteaseMusic
//
//  Created by xjbeta on 2019/4/20.
//  Copyright © 2019 xjbeta. All rights reserved.
//

import Cocoa

class PlaylistCollectionViewItemView: NSView {

    var isSelected: Bool = false {
        didSet {
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let selectionRect = NSInsetRect(bounds, 0, 0)
        let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 3, yRadius: 3)
        if isSelected {
            NSColor.windowBackgroundColor.setFill()
        } else {
            NSColor.clear.setFill()
        }
        selectionPath.fill()
    }
    
}
