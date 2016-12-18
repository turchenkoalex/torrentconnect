//
//  ApplicationColors.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 20.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import Cocoa
import Foundation

extension NSColor {
    static func applicationHighlightedTableBackground() -> NSColor {
        return NSColor(red: 240/255, green: 238/255, blue: 232/255, alpha: 1.0)
    }
    
    static func applicationHighlightedTableLine() -> NSColor {
        return NSColor(red: 230/255, green: 228/255, blue: 222/255, alpha: 1.0)
    }
    
    static func applicationHighlightedTableTransparentBackground() -> NSColor {
        return NSColor(red: 245/255, green: 244/255, blue: 240/255, alpha: 0.7)
    }
    
    static func applicationHighlightedTableTransparentLine() -> NSColor {
        return NSColor(red: 230/255, green: 228/255, blue: 222/255, alpha: 0.7)
    }
    
    static func applicationTableBackground() -> NSColor {
        return NSColor(red: 249/255, green: 248/255, blue: 244/255, alpha: 1.0)
    }
    
    static func applicationTableLine() -> NSColor {
        return NSColor(red: 227/255, green: 227/255, blue: 223/255, alpha: 1.0)
    }

    static func applicationTextColor() -> NSColor {
        return NSColor(red: 79/255, green: 79/255, blue: 77/255, alpha: 1.0)
    }
    
    static func applicationSecondaryTextColor() -> NSColor {
        return NSColor(red: 145/255, green: 145/255, blue: 142/255, alpha: 1.0)
    }
    
    static func applicationGrayColor() -> NSColor {
        return NSColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1.0)
    }
}
