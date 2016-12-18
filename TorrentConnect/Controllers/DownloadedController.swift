//
//  DownloadedController.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 15.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import Foundation

class DownloadedController {
    fileprivate var _active = [Int]()
    fileprivate var _attachedHandler: Disposable?
    
    func inject() {
        _attachedHandler = TransmissionConnectManager.shared.fetchTorrentsEvent.addHandler(self, handler: DownloadedController.fetchTorrents)
    }
    
    func fetchTorrents(_ torrents: [Torrent]) {
        let downloaded = torrents.filter { $0.progress == 1 }.map { $0.id }
        for id in downloaded {
            if _active.contains(id) {
                let torrent = torrents.filter { $0.id == id }.first
                if let torrent = torrent {
                    notify(torrent)
                }
            }
        }
        _active = torrents.filter { $0.progress < 1 }.map { $0.id }
    }
    
    func notify(_ torrent: Torrent) {
        let notification = NSUserNotification()
        notification.subtitle = "Download complete";
        notification.informativeText = "Torrent " + torrent.name + " already downloaded!";
        notification.soundName = NSUserNotificationDefaultSoundName;
        notification.userInfo = ["id": torrent.id];
        NSUserNotificationCenter.default.deliver(notification)
    }
}
