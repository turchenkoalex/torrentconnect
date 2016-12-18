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
    
    func inLocation(_ val: String) -> Bool {
        return val.contains(location)
    }
}

struct TorrentLocations {
    static var locations = [
        TorrentLocation(name: "Movies", location: "/downloads/movies"),
        TorrentLocation(name: "Shows", location: "/downloads/shows"),
        TorrentLocation(name: "Files", location: "/downloads/files")
    ]
    
    static func all() -> [TorrentLocation] {
        return locations
    }
}
