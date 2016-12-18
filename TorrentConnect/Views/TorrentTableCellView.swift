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
        switch(_status) {
        case .stopped:
            return #imageLiteral(resourceName: "play")
        default:
            return #imageLiteral(resourceName: "pause")
        }
    }
    
    func torrentStateImage() -> NSImage {
        switch(_status) {
        case .download:
            return #imageLiteral(resourceName: "download")
        case .seed:
            return #imageLiteral(resourceName: "upload")
        default:
            if (_progress < 1) {
                return #imageLiteral(resourceName: "wait")
            } else {
                return #imageLiteral(resourceName: "completed")
            }
        }
    }
    
    func setupView(_ torrent: Torrent) {
        initializeView()
        
        _id = torrent.id
        _status = torrent.status
        _previousStatus = torrent.status
        _progress = torrent.progress
        
        if (self.textField!.stringValue != torrent.name) {
            self.textField!.stringValue = torrent.name
        }
        if (torrent.progress < 1) {
            if self.progressLabel.doubleValue != torrent.progress {
                self.progressLabel.doubleValue = torrent.progress
            }
        } else {
            if (self.progressLabel.stringValue != "") {
                self.progressLabel.stringValue = ""
            }
        }
    
//        recalcDownloadFrames()
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
            NSColor.applicationGrayColor().setFill()
            NSColor.applicationGrayColor().setStroke()
            
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
            TransmissionConnectManager.shared.startTorrents([_id]) {
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
            TransmissionConnectManager.shared.stopTorrents([_id]) {
                self._status = .stopped
                DispatchQueue.main.async {
                    self.imageButton.image = self.torrentActionImage()
                }
            }
        }
        
    }
}
