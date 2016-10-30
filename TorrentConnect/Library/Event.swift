//
//  Event.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 15.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

open class Event<T> {
    public typealias EventHandler = (T) -> ()
    fileprivate var eventHandlers = [Invocable]()
    
    open func raise(_ data: T) {
        for handler in self.eventHandlers {
            handler.invoke(data)
        }
    }
    
    open func addHandler<U: AnyObject>(_ target: U, handler: @escaping (U) -> EventHandler) -> Disposable {
        let wrapper = EventHandlerWrapper(target: target, handler: handler, event: self)
        eventHandlers.append(wrapper)
        return wrapper
    }
}

private protocol Invocable: class {
    func invoke(_ data: Any)
}

private class EventHandlerWrapper<T: AnyObject, U> : Invocable, Disposable {
    weak var target: T?
    let handler: (T) -> (U) -> ()
    let event: Event<U>
    
    init(target: T?, handler: @escaping (T) -> (U) -> (), event: Event<U>) {
        self.target = target
        self.handler = handler
        self.event = event;
    }
    
    func invoke(_ data: Any) -> () {
        if let t = target {
            handler(t)(data as! U)
        }
    }
    
    func dispose() {
        event.eventHandlers = event.eventHandlers.filter { $0 !== self }
    }
}

public protocol Disposable {
    func dispose()
}
