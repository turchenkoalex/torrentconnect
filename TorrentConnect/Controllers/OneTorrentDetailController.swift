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
    var torrent = Torrent(id: 0, name: "", status: .download, progress: 0, downloadDir: "", position: 0)
    var files = [TorrentFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func setupModel(_ model: Torrent) {
        let changed = torrent.id != model.id
        torrent = model
        
        torrentName.stringValue = torrent.name
        torrentName.toolTip = torrent.name
        progressLabel.doubleValue = torrent.progress
        
        self.updateStartStopButton()
        
        if changed {
            files = []
            DispatchQueue.main.async {
                self.filesOutline.reloadData()
            }
        }
        
        TransmissionConnectManager.sharedInstance.getFiles([torrent.id]) { files in
            self.files = files
            DispatchQueue.main.async {
                self.filesOutline.reloadData()
            }
        }
    }
    
    
    func updateStartStopButton() {
        let title = (self.torrent.status == .stopped) ? "Start" : "Stop"
        DispatchQueue.main.async {
            self.startStopButton.title = title
        }
    }
    
    @IBAction func deleteClick(_ sender: AnyObject) {
        TransmissionConnectManager.sharedInstance.deleteTorrents([torrent.id]) {
            self.hide()
        }
    }
    
    func changeTorrentStatus(_ status: TorrentStatus) {
        self.torrent = Torrent(id: torrent.id, name: torrent.name, status: status, progress: torrent.progress, downloadDir: torrent.downloadDir, position: torrent.position)
    }
    
    @IBAction func startStopClick(_ sender: AnyObject) {
        if (self.torrent.status == .stopped) {
            TransmissionConnectManager.sharedInstance.startTorrents([torrent.id]) {
                self.changeTorrentStatus(.download)
                self.updateStartStopButton()
            }
        } else {
            TransmissionConnectManager.sharedInstance.stopTorrents([torrent.id]) {
                self.changeTorrentStatus(.stopped)
                self.updateStartStopButton()
            }
        }
    }
}

extension OneTorrentDetailController: NSOutlineViewDelegate, NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return files.count
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return index
    }

    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {

        if let index = item as? Int {
            
            if self.files.count <= index {
                return nil
            }
            
            let torrentFile = self.files[index]
            
            if tableColumn?.identifier == "file" {
                return torrentFile.name
            }
            if tableColumn?.identifier == "size" {
                return torrentFile.length
            }
            if tableColumn?.identifier == "wants" {
                return torrentFile.wants
            }
            if tableColumn?.identifier == "progress" {
                return Double(torrentFile.bytesCompleted) / Double(torrentFile.length)
            }
        }
        
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
        
        if let index = item as? Int {

            guard
                tableColumn?.identifier == "wants",
                let wants = object as? Bool
                else {
                    return
            }
            let torrentFile = self.files[index]
            
            self.files[index] = TorrentFile(id: torrentFile.id, torrentId: torrentFile.torrentId, name: torrentFile.name
                , length: torrentFile.length, bytesCompleted: torrentFile.bytesCompleted, wants: wants)
            var wanted : [Int] = []
            var unwanted : [Int] = []
            
            if wants {
                wanted.append(torrentFile.id)
            } else {
                unwanted.append(torrentFile.id)
            }
            
            TransmissionConnectManager.sharedInstance.wantFiles(forTorrent: torrent.id, wanted: wanted, unwanted: unwanted) {
                
            }
        }
    }
}
