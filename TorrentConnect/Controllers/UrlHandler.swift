//
//  UrlHandler.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 19.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import Foundation

class UrlHandler {
    @objc func openUrlEvent(_ event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        if let url = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue {
            TransmissionConnectManager.shared.addTorrent(url: url, success: {
                
            })
        }
    }
}
