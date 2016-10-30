//
//  TorrentTableRowView.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 20.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

class TorrentTableRowView: NSTableRowView {

    override func drawSelection(in dirtyRect: NSRect) {
        if (selectionHighlightStyle == NSTableViewSelectionHighlightStyle.none) {
            return
        }
        
        NSColor.applicationHighlightedTableLine().setStroke()
        NSColor.applicationHighlightedTableBackground().setFill()
        
        NSColor.black.setStroke()
        NSColor.lightGray.setFill()
        
        let selectionPath = NSBezierPath(rect: bounds)
        selectionPath.lineWidth = 0.05
        selectionPath.fill()
        selectionPath.stroke()
    }
}
