//
//  TorrentFilter.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 15.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
}

struct TorrentFilter {
    let levinstain = Levinstain()
    
    func containsFilter(value: String) -> (Torrent -> Bool) {
        return { torrent in return torrent.name.lowercaseString.containsString(value) }
    }
    
    func fuzzyFilter(value: String) -> (Torrent -> Bool) {
        let valueLength = value.utf8.count
        let left = value.characters.map { $0 }
        
        return { torrent in
            var name = torrent.name.lowercaseString
            
            if (name.containsString(value)) {
                return true
            }
            
            if (name.utf8.count < valueLength) {
                return false
            } else {
                name = name[0...valueLength-1]
            }
            
            return self.levinstain.distance(left, right: name.characters.map { $0 }) < 3
        }
    }
    
    func filter(value: String, torrents: [Torrent]) -> [Torrent] {
        let lowerValue = value.lowercaseString
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
