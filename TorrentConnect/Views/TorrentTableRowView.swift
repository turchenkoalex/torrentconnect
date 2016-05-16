//
//  TorrentTableRowView.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 20.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

class TorrentTableRowView: NSTableRowView {

    override func drawSelectionInRect(dirtyRect: NSRect) {
        if (selectionHighlightStyle == NSTableViewSelectionHighlightStyle.None) {
            return
        }
        
        NSColor.applicationHighlightedTableLine().setStroke()
        NSColor.applicationHighlightedTableBackground().setFill()
        
        NSColor.blackColor().setStroke()
        NSColor.lightGrayColor().setFill()
        
        let selectionPath = NSBezierPath(rect: bounds)
        selectionPath.lineWidth = 0.5
        selectionPath.fill()
        selectionPath.stroke()
    }
}
