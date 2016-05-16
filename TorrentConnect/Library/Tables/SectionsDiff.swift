//
//  SectionsDiff.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 14.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

struct SectionsDiff {
    let inserted: [Int]
    let deleted: [Int]
    let updated: [Int]
    let sectionsUpdated: [Int]
}

extension SectionsDiff {
    static func getChanges<Element: FullyEquatable>(left: Sections<Element>, right: Sections<Element>) -> SectionsDiff {
        let levinstain = Levinstain()
        let leftRows = left.getRows()
        let rightRows = right.getRows()
        
        if (leftRows.count == 0 || rightRows.count == 0) {
            if (leftRows.count == 0) {
                let inserted = rightRows.enumerate().map { $0.index }
                return SectionsDiff(inserted: inserted, deleted: [], updated: [], sectionsUpdated: [])
            } else {
                let deleted = leftRows.enumerate().map { $0.index }
                return SectionsDiff(inserted: [], deleted: deleted, updated: [], sectionsUpdated: [])
            }
        }
        
        let path = levinstain.findPath(leftRows, right: rightRows)
        
        var inserted = [Int]()
        var updated = [Int]()
        var deleted = [Int]()
        var sectionsUpdated = [Int]()
        
        for action in path {
            switch action.operation {
            case .Insert:
                inserted.append(action.rightIndex!)
                break
            case .Delete:
                deleted.append(action.leftIndex!)
                break
            case .Replace:
                inserted.append(action.rightIndex!)
                deleted.append(action.leftIndex!)
                break
            case .None:
                if let leftItem = action.left, rightItem = action.right {
                    if (!leftItem.isFullyEqual(rightItem)) {
                        if case .First(_) = rightItem.value {
                            sectionsUpdated.append(action.rightIndex!)
                        } else {
                            updated.append(action.rightIndex!)
                        }
                    }
                }
            }
        }
        
        return SectionsDiff(inserted: inserted, deleted: deleted, updated: updated, sectionsUpdated: sectionsUpdated)
    }
}