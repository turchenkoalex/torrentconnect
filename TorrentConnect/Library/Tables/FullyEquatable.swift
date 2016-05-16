//
//  FullyEquitable.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 15.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

protocol FullyEquatable {
    func isFullyEqual(value: Self) -> Bool
}