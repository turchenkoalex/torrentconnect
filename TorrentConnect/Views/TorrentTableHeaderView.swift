//
//  TorrentTableHeaderView.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 19.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

class TorrentTableHeaderView: NSTableCellView {
    
    static let DefaultHeight: CGFloat = 26
    @IBOutlet weak var countLabel: NSButton!
    @IBOutlet weak var toggler: NSButton!
    
    private var _title: String!
    private var _toggleSection: () -> () = { () in }
    private var _collapsed: Bool = false
    private var _count: Int = 0
    
    func setupView(model: Section<TorrentModel>, toggleSection: () -> ()) {
        _title = model.title
        _collapsed = model.collapsed
        _toggleSection = toggleSection
        _count = model.elements.count
        
        updateControls()
    }
    
    private func updateControls() {
        textField!.stringValue = _title
        countLabel!.title = String(_count)
        if (_collapsed) {
            toggler!.state = NSOffState
        } else {
            toggler!.state = NSOnState
        }
    }
    
    @IBAction func countClick(sender: AnyObject) {
        _toggleSection()
    }
    
    @IBAction func toggleClick(sender: AnyObject) {
        _toggleSection()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        NSColor.applicationHighlightedTableTransparentLine().setStroke()
        NSColor.applicationHighlightedTableTransparentBackground().setFill()
        let selectionPath = NSBezierPath(rect: bounds)
        selectionPath.lineWidth = 0.5
        selectionPath.fill()
        selectionPath.stroke()
    }
}
