//
//  Levinstain.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 14.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

enum LevinstainOperation {
    case none
    case insert
    case delete
    case replace
}

struct LevinstainItem<Element> {
    let left: Element?
    let right: Element?
    let leftIndex: Int?
    let rightIndex: Int?
    let cost: Int
    let operation: LevinstainOperation
}

struct Levinstain {
    
    func solve<Element : Equatable>(_ left: [Element], right: [Element]) -> [[LevinstainItem<Element>]] {
        
        let n = left.count
        let m = right.count
        
        let emptyValue = LevinstainItem<Element>(left: nil, right: nil, leftIndex: nil, rightIndex: nil, cost: 0, operation: .none)
        let row = [LevinstainItem<Element>](repeating: emptyValue, count: m+1)
        var matrix = [[LevinstainItem<Element>]](repeating: row, count: n+1)
        
        for i in 1...n { matrix[i][0] = LevinstainItem<Element>(left: left[i-1], right: nil, leftIndex: i-1, rightIndex: nil, cost: i, operation: .delete) }
        for j in 1...m { matrix[0][j] = LevinstainItem<Element>(left: nil, right: right[j-1], leftIndex: nil, rightIndex: j-1, cost: j, operation: .insert) }
        
        for i in 1...n {
            let l = left[i-1]
            
            for j in 1...m {
                let r = right[j-1]
                
                let cost = l == r ? 0 : 1
                let insertCost  = matrix[i][j-1].cost
                let deleteCost  = matrix[i-1][j].cost
                let replaceCost = matrix[i-1][j-1].cost + cost
                
                if(insertCost < deleteCost && insertCost < replaceCost) {
                    matrix[i][j] = LevinstainItem<Element>(left: nil, right: r, leftIndex: nil, rightIndex: j-1, cost: insertCost + 1, operation: .insert)
                } else if (deleteCost < replaceCost) {
                    matrix[i][j] = LevinstainItem<Element>(left: l, right: nil, leftIndex: i-1, rightIndex: nil, cost: deleteCost + 1, operation: .delete)
                } else {
                    let operation = (cost == 0) ? LevinstainOperation.none : LevinstainOperation.replace
                    matrix[i][j] = LevinstainItem<Element>(left: l, right: r, leftIndex: i-1, rightIndex: j-1, cost: replaceCost, operation: operation)
                }
            }
        }
        
        return matrix
    }
    
    func findPath<Element : Equatable>(_ left: [Element], right: [Element]) -> [LevinstainItem<Element>] {
        var path = [LevinstainItem<Element>]()
        let matrix = solve(left, right: right)
        var i = left.count
        var j = right.count
        
        repeat {
            let step = matrix[i][j]
            path.append(step)
            switch step.operation {
            case .none, .replace:
                i -= 1;
                j -= 1;
                break
            case .delete:
                i -= 1
                break
            case .insert:
                j -= 1
                break
            }
            
        } while (i != 0 || j != 0)
        
        return path.reversed()
    }
    
    func distance<Element : Equatable>(_ left: [Element], right: [Element]) -> Int {
        let matrix = solve(left, right: right)
        return matrix[left.count][right.count].cost
    }
}
