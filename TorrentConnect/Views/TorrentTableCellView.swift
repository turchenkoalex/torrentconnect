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
    private var _previousStatus: TorrentStatus = TorrentStatus.Stopped
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
            if (_progress < 1) {
                imageAsset = .Wait
            } else {
                imageAsset = .Completed
            }
        }
        return NSImage(assetIdentifier: imageAsset)
    }
    
    func setupView(torrent: Torrent) {
        initializeView()
        
        _id = torrent.id
        _status = torrent.status
        _previousStatus = torrent.status
        _progress = torrent.progress
        
        textField!.stringValue = torrent.name
        if (torrent.progress < 1) {
            progressLabel.doubleValue = torrent.progress
            progressLabel.hidden = false
        } else {
            progressLabel.stringValue = ""
            progressLabel.hidden = true
        }
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
        
        if (_progress < 1) {
            NSColor.applicationHighlightedTableBackground().setStroke()
            NSColor.applicationHighlightedTableBackground().setFill()
            
            let x = dirtyRect.size.width * CGFloat(_progress)
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
            TransmissionConnectManager.sharedInstance.startTorrents([_id]) {
                if (self._progress < 1) {
                    self._status = .Download
                } else {
                    self._status = .Seed
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.imageButton.image = self.torrentActionImage()
                }
            }
            
        default:
            _previousStatus = _status
            TransmissionConnectManager.sharedInstance.stopTorrents([_id]) {
                self._status = .Stopped
                dispatch_async(dispatch_get_main_queue()) {
                    self.imageButton.image = self.torrentActionImage()
                }
            }
        }
        
    }
}
