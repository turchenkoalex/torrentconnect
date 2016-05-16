//
//  TableController.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 13.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

struct TableController<Element: Equatable where Element: FullyEquatable> {
    var groupBy: ([Element]) -> [(String, [Element])]
    
    init(groupBy: ([Element]) -> [(String, [Element])]) {
        self.groupBy = groupBy
    }
    
    func getSections(elements: [Element]) -> Sections<Element>{
        let grouped = self.groupBy(elements).sort { $0.0.0 < $0.1.0 }
        let sections = grouped.map { (title, elements) in return Section(title: title, collapsed: false, elements: elements) }
        return Sections(sections: sections)
    }
    
    func getSections(elements: [Element], sections: Sections<Element>) -> Sections<Element> {
        let grouped = self.groupBy(elements).sort { $0.0.0 < $0.1.0 }
        let sections = grouped.map { (title, elements) in return Section(title: title, collapsed: sections.isCollapsed(title), elements: elements) }
        return Sections(sections: sections)
    }
}