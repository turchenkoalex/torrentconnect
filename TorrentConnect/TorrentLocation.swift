//
//  TorrentLocation.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 25.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

struct TorrentLocation {
    let name: String
    let location: String
    
    func inLocation(val: String) -> Bool {
        return val.containsString(location)
    }
}

struct TorrentLocations {
    static func all() -> [TorrentLocation] {
        return [
            TorrentLocation(name: "Movies", location: "/downloads/movies"),
            TorrentLocation(name: "Shows", location: "/downloads/shows"),
            TorrentLocation(name: "Files", location: "/downloads/files")
        ]
    }
}