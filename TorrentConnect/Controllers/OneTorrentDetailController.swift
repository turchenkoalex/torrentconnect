//
//  OneTorrentDetailController.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 20.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import Cocoa

class OneTorrentDetailController: NSViewController {
    @IBOutlet weak var startStopButton: NSButton!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var filesOutline: NSOutlineView!
    @IBOutlet weak var torrentName: NSTextField!
    
    var hide: () -> () = { }
    var torrent = Torrent(id: 0, name: "", status: .Download, progress: 0, downloadDir: "", position: 0)
    var files = [TorrentFile]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    func setupModel(model: Torrent) {
        torrent = model
        
        torrentName.stringValue = torrent.name
        torrentName.toolTip = torrent.name
        progressLabel.doubleValue = torrent.progress
        
        files = []
        
        self.updateStartStopButton()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.filesOutline.reloadData()
        }
        
        TransmissionConnectManager.sharedInstance.getFiles([torrent.id]) { files in
            self.files = files
            dispatch_async(dispatch_get_main_queue()) {
                self.filesOutline.reloadData()
            }
        }
    }
    
    
    func updateStartStopButton() {
        let title = (self.torrent.status == .Stopped) ? "Start" : "Stop"
        dispatch_async(dispatch_get_main_queue()) {
            self.startStopButton.title = title
        }
    }
    
    @IBAction func deleteClick(sender: AnyObject) {
        TransmissionConnectManager.sharedInstance.deleteTorrents([torrent.id]) {
            self.hide()
        }
    }
    
    func changeTorrentStatus(status: TorrentStatus) {
        self.torrent = Torrent(id: torrent.id, name: torrent.name, status: status, progress: torrent.progress, downloadDir: torrent.downloadDir, position: torrent.position)
    }
    
    @IBAction func startStopClick(sender: AnyObject) {
        if (self.torrent.status == .Stopped) {
            TransmissionConnectManager.sharedInstance.startTorrents([torrent.id]) {
                self.changeTorrentStatus(.Download)
                self.updateStartStopButton()
            }
        } else {
            TransmissionConnectManager.sharedInstance.stopTorrents([torrent.id]) {
                self.changeTorrentStatus(.Stopped)
                self.updateStartStopButton()
            }
        }
    }
}

@objc class myobj : NSObject {
    let file: NSString
    let size: NSNumber
    init(torrentFile: TorrentFile) {
        file = NSString(string: torrentFile.name)
        size = NSNumber(integer: torrentFile.length)
    }
}

extension OneTorrentDetailController: NSOutlineViewDelegate, NSOutlineViewDataSource {
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        return files.count
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        return myobj(torrentFile: files[index])
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        
//        if let o = item as? myobj {
//            if tableColumn?.identifier == "file" {
//                return o.file
//            }
//            if tableColumn?.identifier == "size" {
//                return o.size
//            }
//            
//        }
        
        return ""
    }
}