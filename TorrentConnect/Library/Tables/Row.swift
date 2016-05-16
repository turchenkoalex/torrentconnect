//
//  Row.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 14.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

struct Row<Group, Element where Group: Equatable, Group: FullyEquatable, Element: Equatable, Element: FullyEquatable> {
    let value: Either<Group, Element>
}

extension Row: Equatable, FullyEquatable {
    func isFullyEqual(value: Row<Group, Element>) -> Bool {
        let lhs = self.value
        let rhs = value.value
     
        switch lhs {
        case let .First(lf):
            switch rhs {
            case let .First(rf):
                return lf.isFullyEqual(rf)
            default:
                return false
            }
        case let .Second(ls):
            switch rhs {
            case let .Second(rs):
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