//
//  Either.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 26.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

enum Either<TFirst, TSecond> {
    case first(TFirst)
    case second(TSecond)
}

func ==<TFirst: Equatable, TSecond: Equatable>(lhs: Either<TFirst, TSecond>, rhs: Either<TFirst, TSecond>) -> Bool {
    switch lhs {
    case let .first(lf):
        switch rhs {
        case let .first(rf):
            return lf == rf
        default:
            return false
        }
    case let .second(ls):
        switch rhs {
        case let .second(rs):
            return ls == rs
        default:
            return false
        }
    }
}
