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
    
    func setupModel(_ torrents: [Torrent]) {
        ids = torrents.map { $0.id }
        progressLabel.doubleValue = totalProgress(torrents.map { $0.progress })
        
        let stoppedCount = torrents.filter({ $0.status == .stopped }).count
        
        torrentCountLabel.integerValue = torrents.count
        activedLabel.integerValue = torrents.count - stoppedCount
        stoppedLabel.integerValue = stoppedCount
    }
    
    func totalProgress(_ items: [Double]) -> Double {
        let sum = items.reduce(0, (+))
        return sum / Double(items.count)
    }
    
    @IBAction func deleteAllClick(_ sender: AnyObject) {
        TransmissionConnectManager.shared.deleteTorrents(ids) {
            self.hide()
        }
    }
    
    @IBAction func pauseAllClick(_ sender: AnyObject) {
        TransmissionConnectManager.shared.stopTorrents(ids) {
            
        }
    }
    
    @IBAction func startAllClick(_ sender: AnyObject) {
        TransmissionConnectManager.shared.startTorrents(ids) {
            
        }
    }
}
