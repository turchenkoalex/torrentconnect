//
//  JsonPrintable.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 16.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

protocol JsonPrintable {
    func toJson() -> String
}

extension String: JsonPrintable {
    func toJson() -> String {
        return "\"" + self + "\""
    }
}

extension Int: JsonPrintable {
    func toJson() -> String {
        return String(self)
    }
}

extension Bool: JsonPrintable {
    func toJson() -> String {
        if (self) {
            return "true"
        }
        
        return "false"
    }
}

extension Optional where Wrapped: JsonPrintable {
    func toJson() -> String {
        switch self {
        case let .some(wrapped):
            return wrapped.toJson()
        default:
            return "null"
        }
    }
}

extension Dictionary: JsonPrintable {
    func toJson() -> String {
        let pairs = self.map { (key, value) in
            return (String(describing: key), JsonValue(value: (value as? JsonPrintable)))
        }.map { (key, value) in
            return key.toJson() + ":" + value.toJson()
        }
        return "{" + pairs.joined(separator: ",") + "}"
    }
}

extension Array: JsonPrintable {
    func toJson() -> String {
        let items = self.map { JsonValue(value: ($0 as? JsonPrintable)).toJson() }
        return "[" + items.joined(separator: ",") + "]"
    }
}

func toJson(_ jsonTuple: (String, JsonPrintable)) -> String {
    return toJson(jsonTuple.0, jsonTuple.1)
}

func toJson(_ name: String, value: JsonPrintable) -> String {
    return name.toJson() + ":" + value.toJson()
}

struct JsonValue: JsonPrintable {
    let value: JsonPrintable?
    
    func toJson() -> String {
        return value?.toJson() ?? "null"
    }
}

struct JsonObject: JsonPrintable {
    let attributes: [String: JsonPrintable]
    
    func toJson() -> String {
        return attributes.toJson()
    }
}

struct JsonArray: JsonPrintable {
    let elements: [JsonPrintable]
    
    func toJson() -> String {
        return elements.toJson()
    }
}
