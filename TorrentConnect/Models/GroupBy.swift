//
//  GroupBy.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 19.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

struct GroupBy<Group: Hashable, Element> {
    let keySelector: ((Element) -> Group)
    
    func groupBy(_ elements: [Element]) -> [(Group, [Element])] {
        var sections = [Group : (Group, [Element])]()
        
        for element in elements {
            let key = keySelector(element)
            if var section = sections[key] {
                section.1.append(element)
                sections[key] = section
            } else {
                sections[key] = (key, [element])
            }
        }
        
        return sections.map { $0.1 }
    }
}

