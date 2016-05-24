//
//  BadgeController.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 15.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import Foundation
import AppKit

class BadgeController {
    private let _dockTile = NSDockTile()
    
    func inject() {
        TransmissionConnectManager.sharedInstance.fetchTorrentsEvent.addHandler(self, handler: BadgeController.fetchTorrents)
    }
    
    func fetchTorrents(torrents: [Torrent]) {
        let downloadCount = torrents.filter { $0.status == .Download }.count
        if (downloadCount > 0) {
            _dockTile.badgeLabel = String(downloadCount)
        } else {
            _dockTile.badgeLabel = nil
        }
    }
}