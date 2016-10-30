//
//  TorrentStatus.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 24.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Foundation

enum TorrentStatus: Int {
    case stopped       = 0
    case waitCheck     = 1
    case check         = 2
    case waitDownload  = 3
    case download      = 4
    case waitSeed      = 5
    case seed          = 6
}
