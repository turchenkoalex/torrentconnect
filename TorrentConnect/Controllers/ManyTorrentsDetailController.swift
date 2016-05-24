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
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var activedLabel: NSTextField!
    @IBOutlet weak var stoppedLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func setupModel(torrents: [Torrent]) {
        ids = torrents.map { $0.id }
        progressLabel.doubleValue = totalProgress(torrents.map { $0.progress })
        
        let stoppedCount = torrents.filter({ $0.status == .Stopped }).count
        
        torrentCountLabel.integerValue = torrents.count
        activedLabel.integerValue = torrents.count - stoppedCount
        stoppedLabel.integerValue = stoppedCount
    }
    
    func totalProgress(items: [Double]) -> Double {
        let sum = items.reduce(0, combine: (+))
        return sum / Double(items.count)
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
