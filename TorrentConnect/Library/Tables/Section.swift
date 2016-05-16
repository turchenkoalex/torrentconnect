//
//  Section.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 13.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

struct Section<Element> {
    let title: String
    let collapsed: Bool
    let elements: [Element]
}

extension Section: Equatable, FullyEquatable {
    func isFullyEqual(value: Section) -> Bool {
        return self.title == value.title
            && self.collapsed == value.collapsed
            && self.elements.count == value.elements.count
    }
}

func ==<Element>(lhs: Section<Element>, rhs: Section<Element>) -> Bool {
    return lhs.title == rhs.title
}