//
//  Levinstain.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 14.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

enum LevinstainOperation {
    case None
    case Insert
    case Delete
    case Replace
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
    
    func solve<Element : Equatable>(left: [Element], right: [Element]) -> [[LevinstainItem<Element>]] {
        
        let n = left.count
        let m = right.count
        
        let emptyValue = LevinstainItem<Element>(left: nil, right: nil, leftIndex: nil, rightIndex: nil, cost: 0, operation: .None)
        let row = [LevinstainItem<Element>](count: m+1, repeatedValue: emptyValue)
        var matrix = [[LevinstainItem<Element>]](count: n+1, repeatedValue: row)
        
        for i in 1...n { matrix[i][0] = LevinstainItem<Element>(left: left[i-1], right: nil, leftIndex: i-1, rightIndex: nil, cost: i, operation: .Delete) }
        for j in 1...m { matrix[0][j] = LevinstainItem<Element>(left: nil, right: right[j-1], leftIndex: nil, rightIndex: j-1, cost: j, operation: .Insert) }
        
        for i in 1...n {
            let l = left[i-1]
            
            for j in 1...m {
                let r = right[j-1]
                
                let cost = l == r ? 0 : 1
                let insertCost  = matrix[i][j-1].cost
                let deleteCost  = matrix[i-1][j].cost
                let replaceCost = matrix[i-1][j-1].cost + cost
                
                if(insertCost < deleteCost && insertCost < replaceCost) {
                    matrix[i][j] = LevinstainItem<Element>(left: nil, right: r, leftIndex: nil, rightIndex: j-1, cost: insertCost + 1, operation: .Insert)
                } else if (deleteCost < replaceCost) {
                    matrix[i][j] = LevinstainItem<Element>(left: l, right: nil, leftIndex: i-1, rightIndex: nil, cost: deleteCost + 1, operation: .Delete)
                } else {
                    let operation = (cost == 0) ? LevinstainOperation.None : LevinstainOperation.Replace
                    matrix[i][j] = LevinstainItem<Element>(left: l, right: r, leftIndex: i-1, rightIndex: j-1, cost: replaceCost, operation: operation)
                }
            }
        }
        
        return matrix
    }
    
    func findPath<Element : Equatable>(left: [Element], right: [Element]) -> [LevinstainItem<Element>] {
        var path = [LevinstainItem<Element>]()
        let matrix = solve(left, right: right)
        var i = left.count
        var j = right.count
        
        repeat {
            let step = matrix[i][j]
            path.append(step)
            switch step.operation {
            case .None, .Replace:
                i -= 1;
                j -= 1;
                break
            case .Delete:
                i -= 1
                break
            case .Insert:
                j -= 1
                break
            }
            
        } while (i != 0 || j != 0)
        
        return path.reverse()
    }
    
    func distance<Element : Equatable>(left: [Element], right: [Element]) -> Int {
        let matrix = solve(left, right: right)
        return matrix[left.count][right.count].cost
    }
}
