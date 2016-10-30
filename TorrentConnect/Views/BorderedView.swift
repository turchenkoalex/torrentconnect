//
//  BorderedView.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 20.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

class BorderedView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSColor.applicationHighlightedTableLine().setStroke()
        NSColor.applicationTableBackground().setFill()
        let selectionPath = NSBezierPath(rect: bounds)
        selectionPath.lineWidth = 1
        selectionPath.fill()
        selectionPath.stroke()
    }
    
}
