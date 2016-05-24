//
//  OneTorrentDetailController.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 20.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import Cocoa

class OneTorrentDetailController: NSViewController {
    @IBOutlet weak var torrentName: NSTextField!
    @IBOutlet weak var startStopButton: NSButton!
    @IBOutlet weak var progressLabel: NSTextField!
    
    var hide: () -> () = { }
    var id: Int = 0
    var state: TorrentStatus = .Stopped
    var progress: Double = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    func setupModel(torrent: Torrent) {
        id = torrent.id
        torrentName.stringValue = torrent.name
        state = torrent.status
        progress = torrent.progress
        updateStartStopButton()
        updateProgress()
        
        TransmissionConnectManager.sharedInstance.getFiles([id]) { files in
            print(files)
        }
    }
    
    func updateProgress() {
        progressLabel.doubleValue = progress
    }
    
    func updateStartStopButton() {
        let title = (self.state == .Stopped) ? "Start" : "Stop"
        dispatch_async(dispatch_get_main_queue()) {
            self.startStopButton.title = title
        }
    }
    
    @IBAction func deleteClick(sender: AnyObject) {
        TransmissionConnectManager.sharedInstance.deleteTorrents([id]) {
            self.hide()
        }
    }
    
    @IBAction func startStopClick(sender: AnyObject) {
        if (state == .Stopped) {
            TransmissionConnectManager.sharedInstance.startTorrents([id]) {
                self.state = .Download
                self.updateStartStopButton()
            }
        } else {
            TransmissionConnectManager.sharedInstance.stopTorrents([id]) {
                self.state = .Stopped
                self.updateStartStopButton()
            }
        }
    }
}
