//
//  TorrentFile.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 24.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

public struct TorrentFile {
    let id: Int
    let torrentId: Int
    let name: String
    let length: Int
    let bytesCompleted: Int
    let wants: Bool
}
