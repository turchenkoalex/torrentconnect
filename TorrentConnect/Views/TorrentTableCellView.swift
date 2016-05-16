//
//  TorrentTableCellView.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 20.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa

class TorrentTableCellView: NSTableCellView {
    
    static let DefaultHeight: CGFloat = 56
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var imageButton: NSButton!
    private var viewInitialized = false
    
    private var _id: Int = 0
    private var _status: TorrentStatus = TorrentStatus.Stopped
    private var _progress: Double = 0
    
    func initializeView() {
        if (viewInitialized) {
            return
        }
        viewInitialized = true
        
        let trackingArea = NSTrackingArea(rect: imageButton.bounds, options: [.MouseEnteredAndExited, .ActiveAlways], owner: self, userInfo: nil)
        imageButton.addTrackingArea(trackingArea)
    }

    override func mouseEntered(theEvent: NSEvent) {
        imageButton.image = torrentActionImage()
    }
    
    override func mouseExited(theEvent: NSEvent) {
        imageButton.image = torrentStateImage()
    }
    
    func torrentActionImage() -> NSImage {
        var imageAsset: NSImage.AssetIdentifier
        switch(_status) {
        case .Stopped:
            imageAsset = .Play
        default:
            imageAsset = .Pause
        }
        return NSImage(assetIdentifier: imageAsset)
        
    }
    
    func torrentStateImage() -> NSImage {
        var imageAsset: NSImage.AssetIdentifier
        switch(_status) {
        case .Download:
            imageAsset = .Download
        case .Seed:
            imageAsset = .Upload
        default:
            if (_progress < 100) {
                imageAsset = .Wait
            } else {
                imageAsset = .Completed
            }
        }
        return NSImage(assetIdentifier: imageAsset)
    }
    
    func setupView(torrent: TorrentModel) {
        initializeView()
        
        _id = torrent.id
        _status = torrent.status
        _progress = torrent.progress
        
        textField!.stringValue = torrent.name
        progressLabel!.stringValue = (torrent.progress < 100) ? String(Int(torrent.progress)) + "%" : ""
        imageButton.image = torrentStateImage()
    }
    
    override var backgroundStyle: NSBackgroundStyle {
        get {
            return super.backgroundStyle
        }
        set (value) {
            super.backgroundStyle = value
            if (value == NSBackgroundStyle.Dark) {
                setAsSelected()
            } else {
                setAsUnselected()
            }
        }
    }

    func setAsSelected() {
        textField?.textColor = NSColor.whiteColor()
    }

    func setAsUnselected() {
        textField?.textColor = NSColor.labelColor()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        if (dirtyRect.size.height < bounds.size.height) {
            super.drawRect(dirtyRect)
            return
        }
        
        if (_progress < 100) {
            NSColor.applicationHighlightedTableBackground().setStroke()
            NSColor.applicationHighlightedTableBackground().setFill()
            
            let x = dirtyRect.size.width / 100 * CGFloat(_progress)
            let progressRect = NSRect(
                x: dirtyRect.origin.x,
                y: dirtyRect.origin.y,
                width: x,
                height: 6)
            
            let selectionPath = NSBezierPath(rect: progressRect)
            selectionPath.stroke()
            selectionPath.fill()
            
            NSColor.blackColor().setStroke()
            NSColor.lightGrayColor().setFill()
        }
    }
    
    @IBAction func startStopClick(sender: AnyObject) {
        switch(_status) {
        case .Stopped:
            TransmissionConnectManager.sharedInstance.startTorrents([_id])
            _status = .Download
        default:
            TransmissionConnectManager.sharedInstance.stopTorrents([_id])
            _status = .Stopped
        }
        imageButton.image = torrentActionImage()
    }
}
