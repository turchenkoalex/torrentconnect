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
    var hide: () -> () = { }
    var id: Int = 0
    var state: TorrentStatus = .Stopped
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    func setupModel(torrent: TorrentModel) {
        id = torrent.id
        torrentName.stringValue = torrent.name
        state = torrent.status
        updateStartStopButton()
    }
    
    func updateStartStopButton() {
        let title = (self.state == .Stopped) ? "Start" : "Pause"
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
