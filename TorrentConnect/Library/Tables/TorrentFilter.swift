//
//  TorrentFilter.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 15.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = characters.index(startIndex, offsetBy: r.lowerBound)
        let end = characters.index(start, offsetBy: r.upperBound - r.lowerBound)
        return self[Range(start ..< end)]
    }
}

struct TorrentFilter {
    let levinstain = Levinstain()
    
    func containsFilter(_ value: String) -> ((Torrent) -> Bool) {
        return { torrent in return torrent.name.lowercased().contains(value) }
    }
    
    func fuzzyFilter(_ value: String) -> ((Torrent) -> Bool) {
        let valueLength = value.utf8.count
        let left = value.characters.map { $0 }
        
        return { torrent in
            var name = torrent.name.lowercased()
            
            if (name.contains(value)) {
                return true
            }
            
            if (name.utf8.count < valueLength) {
                return false
            } else {
                let end = name.index(name.startIndex, offsetBy: valueLength - 1)
                name = name.substring(to: end)
            }
            
            return self.levinstain.distance(left, right: name.characters.map { $0 }) < 3
        }
    }
    
    func filter(_ value: String, torrents: [Torrent]) -> [Torrent] {
        let lowerValue = value.lowercased()
        if (value.isEmpty) {
            return torrents
        }
        let filtered = torrents.filter(containsFilter(lowerValue))
        if (filtered.count > 0) {
            return filtered
        }
        return torrents.filter(fuzzyFilter(lowerValue))
    }
}
