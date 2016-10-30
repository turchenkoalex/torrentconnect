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
    fileprivate var viewInitialized = false
    
    fileprivate var _id: Int = 0
    fileprivate var _status: TorrentStatus = TorrentStatus.stopped
    fileprivate var _previousStatus: TorrentStatus = TorrentStatus.stopped
    fileprivate var _progress: Double = 0
    
    func initializeView() {
        if (viewInitialized) {
            return
        }
        viewInitialized = true
        
        let trackingArea = NSTrackingArea(rect: imageButton.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        imageButton.addTrackingArea(trackingArea)
    }

    override func mouseEntered(with theEvent: NSEvent) {
        imageButton.image = torrentActionImage()
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        imageButton.image = torrentStateImage()
    }
    
    func torrentActionImage() -> NSImage {
        var imageAsset: NSImage.AssetIdentifier
        switch(_status) {
        case .stopped:
            imageAsset = .Play
        default:
            imageAsset = .Pause
        }
        return NSImage(assetIdentifier: imageAsset)
        
    }
    
    func torrentStateImage() -> NSImage {
        var imageAsset: NSImage.AssetIdentifier
        switch(_status) {
        case .download:
            imageAsset = .Download
        case .seed:
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
    
    func setupView(_ torrent: Torrent) {
        initializeView()
        
        _id = torrent.id
        _status = torrent.status
        _previousStatus = torrent.status
        _progress = torrent.progress
        
//        dispatch_async(dispatch_get_main_queue()) {
            if (self.textField!.stringValue != torrent.name) {
                self.textField!.stringValue = torrent.name
            }
            if (torrent.progress < 1) {
                if self.progressLabel.doubleValue != torrent.progress {
                    Swift.print("Set progress " + String(torrent.progress))
                    self.progressLabel.doubleValue = torrent.progress
                }
            } else {
                if (self.progressLabel.stringValue != "") {
                    self.progressLabel.stringValue = ""
                    Swift.print("Set progress empty")
                }
            }
//        }
        imageButton.image = torrentStateImage()
    }
    
    override var backgroundStyle: NSBackgroundStyle {
        get {
            return super.backgroundStyle
        }
        set (value) {
            super.backgroundStyle = value
            if (value == NSBackgroundStyle.dark) {
                setAsSelected()
            } else {
                setAsUnselected()
            }
        }
    }

    func setAsSelected() {
        textField?.textColor = NSColor.white
    }

    func setAsUnselected() {
        textField?.textColor = NSColor.labelColor
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if (dirtyRect.size.height < bounds.size.height) {
            super.draw(dirtyRect)
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
            
            NSColor.black.setStroke()
            NSColor.lightGray.setFill()
        }
    }
    
    @IBAction func startStopClick(_ sender: AnyObject) {
        switch(_status) {
        case .stopped:
            TransmissionConnectManager.sharedInstance.startTorrents([_id]) {
                if (self._progress < 1) {
                    self._status = .download
                } else {
                    self._status = .seed
                }
                DispatchQueue.main.async {
                    self.imageButton.image = self.torrentActionImage()
                }
            }
            
        default:
            _previousStatus = _status
            TransmissionConnectManager.sharedInstance.stopTorrents([_id]) {
                self._status = .stopped
                DispatchQueue.main.async {
                    self.imageButton.image = self.torrentActionImage()
                }
            }
        }
        
    }
}
