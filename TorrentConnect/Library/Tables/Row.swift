//
//  Row.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 14.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

struct Row<Group, Element> where Group: Equatable, Group: FullyEquatable, Element: Equatable, Element: FullyEquatable {
    let value: Either<Group, Element>
}

extension Row: Equatable, FullyEquatable {
    func isFullyEqual(_ value: Row<Group, Element>) -> Bool {
        let lhs = self.value
        let rhs = value.value
     
        switch lhs {
        case let .first(lf):
            switch rhs {
            case let .first(rf):
                return lf.isFullyEqual(rf)
            default:
                return false
            }
        case let .second(ls):
            switch rhs {
            case let .second(rs):
                return ls.isFullyEqual(rs)
            default:
                return false
            }
        }
    }
}

func ==<Group, Element>(lhs: Row<Group, Element>, rhs: Row<Group, Element>) -> Bool {
    return lhs.value == rhs.value
}
