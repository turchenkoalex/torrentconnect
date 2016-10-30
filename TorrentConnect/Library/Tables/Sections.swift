//
//  Sections.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 13.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

struct Sections<Element: Equatable> where Element: FullyEquatable {
    fileprivate let _sections: [Section<Element>]
    fileprivate let _counts: [Int]
    fileprivate let _totalCount: Int
    
    init(sections: [Section<Element>]) {
        _sections = sections
        _counts = sections.map { $0.collapsed ? 0 : $0.elements.count }
        _totalCount = _counts.reduce(0, (+)) + _counts.count
    }
    
    var totalCount: Int { return self._totalCount }
    
    var sectionsCount: Int { return self._sections.count }
    
    func positionAt(_ index: Int) -> (section: Int, element: Int)? {
        
        if (index < 0) {
            return nil
        }
        
        var bound = 0
        
        for (section, count) in _counts.enumerated() {
            let previousBound = bound
            bound += count + 1
            
            if (index < bound) {
                let element = index - previousBound
                return (section: section, element: element)
            }
        }
        
        return nil
    }
    
    func isGroup(_ index: Int) -> Bool {
        if let position = self.positionAt(index) {
            return position.element == 0
        }
        
        return false
    }
    
    func isElement(_ index: Int) -> Bool {
        return !isGroup(index)
    }

    func elementAt(_ index: Int) -> Element? {
        if let position = positionAt(index) {
            if (position.element > 0) {
                return _sections[position.section].elements[position.element - 1]
            }
        }
        return nil
    }
    
    func sectionAt(_ index: Int) -> Section<Element>? {
        if let position = positionAt(index) {
            if (position.element == 0) {
                let section = _sections[position.section]
                return section
            }
        }
        return nil
    }
    
    func toggleSection(_ title: String) -> Sections {
        for (index, section) in _sections.enumerated() {
            if section.title == title {
                var sections = _sections;
                sections[index] = Section(title: section.title, collapsed: !section.collapsed, elements: section.elements)
                return Sections(sections: sections)
            }
        }
        return self
    }
    
    func sectionAt(_ title: String) -> Section<Element>? {
        for section in _sections {
            if section.title == title {
                return section;
            }
        }
        return nil
    }
    
    func isCollapsed(_ title: String) -> Bool {
        if let section = sectionAt(title) {
            return section.collapsed
        }
        
        return false
    }
    
    func getRows() -> [Row<Section<Element>, Element>] {
        var rows = [Row<Section<Element>, Element>]()
        for section in _sections {
            rows.append(Row(value: .first(section)))
            if (!section.collapsed) {
                let elms = section.elements.map { Row<Section<Element>, Element>(value: .second($0)) }
                rows.append(contentsOf: elms)
            }
        }
        return rows
    }
}
