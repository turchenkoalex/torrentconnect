//
//  TorrentModel.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 19.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

public struct Torrent: Equatable {
    let id: Int
    let name: String
    let status: TorrentStatus
    let progress: Double
    let downloadDir: String
    let position: Int
}

extension Torrent: FullyEquatable {
    func isFullyEqual(_ value: Torrent) -> Bool {
        return
            self.id == value.id
            && self.name == value.name
            && self.progress == value.progress
            && self.status == value.status
            && self.downloadDir == value.downloadDir
            && self.position == value.position
    }
}

public func ==(lhs: Torrent, rhs: Torrent) -> Bool {
    return lhs.id == rhs.id
}
