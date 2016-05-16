//
//  TorrentModel.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 19.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

public struct TorrentModel: Equatable {
    let id: Int
    let name: String
    let status: TorrentStatus
    let progress: Double
    let downloadDir: String
}

extension TorrentModel: FullyEquatable {
    func isFullyEqual(value: TorrentModel) -> Bool {
        return
            self.id == value.id
            && self.name == value.name
            && self.progress == value.progress
            && self.status == value.status
            && self.downloadDir == value.downloadDir
    }
}

public func ==(lhs: TorrentModel, rhs: TorrentModel) -> Bool {
    return lhs.id == rhs.id
}