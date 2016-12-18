//
//  EventQueue.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 30/10/2016.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

struct EventQueue {
    var _events: [() -> ()] = []
    
    mutating func add(_ event: @escaping () -> ()) {
        _events.append(event)
    }
    
    mutating func invoke() {
        while (_events.count > 0) {
            _events.removeFirst()()
        }
    }
}
