//
//  Either.swift
//  TorrentConnect
//
//  Created by Turchenko Alexander on 26.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

enum Either<TFirst, TSecond> {
    case First(TFirst)
    case Second(TSecond)
}

func ==<TFirst: Equatable, TSecond: Equatable>(lhs: Either<TFirst, TSecond>, rhs: Either<TFirst, TSecond>) -> Bool {
    switch lhs {
    case let .First(lf):
        switch rhs {
        case let .First(rf):
            return lf == rf
        default:
            return false
        }
    case let .Second(ls):
        switch rhs {
        case let .Second(rs):
            return ls == rs
        default:
            return false
        }
    }
}