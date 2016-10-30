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
    
    fileprivate var _title: String!
    fileprivate var _toggleSection: () -> () = { () in }
    fileprivate var _collapsed: Bool = false
    fileprivate var _count: Int = 0
    
    func setupView(_ model: Section<Torrent>, toggleSection: @escaping () -> ()) {
        _title = model.title
        _collapsed = model.collapsed
        _toggleSection = toggleSection
        _count = model.elements.count
        
        updateControls()
    }
    
    fileprivate func updateControls() {
        textField!.stringValue = _title
        countLabel!.title = String(_count)
        if (_collapsed) {
            toggler!.state = NSOffState
        } else {
            toggler!.state = NSOnState
        }
    }
    
    @IBAction func countClick(_ sender: AnyObject) {
        _toggleSection()
    }
    
    @IBAction func toggleClick(_ sender: AnyObject) {
        _toggleSection()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.applicationHighlightedTableTransparentLine().setStroke()
        NSColor.applicationHighlightedTableTransparentBackground().setFill()
        let selectionPath = NSBezierPath(rect: bounds)
        selectionPath.lineWidth = 0.5
        selectionPath.fill()
        selectionPath.stroke()
    }
}
