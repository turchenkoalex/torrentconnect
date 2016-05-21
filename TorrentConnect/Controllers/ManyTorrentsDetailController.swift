//
//  ManyTorrentsDetailController.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 21.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import Cocoa

class ManyTorrentsDetailController: NSViewController {

    var hide: () -> () = { }
    var ids: [Int] = []
    @IBOutlet weak var torrentCountLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func setupModel(torrents: [TorrentModel]) {
        ids = torrents.map { $0.id }
        torrentCountLabel.stringValue = String(torrents.count)
    }
    
    @IBAction func deleteAllClick(sender: AnyObject) {
        TransmissionConnectManager.sharedInstance.deleteTorrents(ids) {
            self.hide()
        }
    }
    
    @IBAction func pauseAllClick(sender: AnyObject) {
        TransmissionConnectManager.sharedInstance.stopTorrents(ids) {
            
        }
    }
    
    @IBAction func startAllClick(sender: AnyObject) {
        TransmissionConnectManager.sharedInstance.startTorrents(ids) {
            
        }
    }
}
