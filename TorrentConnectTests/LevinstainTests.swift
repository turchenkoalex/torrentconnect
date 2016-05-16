//
//  LevinstainTests.swift
//  TorrentConnect
//
//  Created by Александр Турченко on 14.05.16.
//  Copyright © 2016 Turchenko Alexander. All rights reserved.
//

import XCTest
@testable import TorrentConnect

class LevinstainTests: XCTestCase {
    
    var subject: Levinstain = Levinstain()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDistance() {
        
        let s1 = "EV".characters.map { $0 }
        let s2 = "NEW".characters.map { $0 }
        
        let d = subject.distance(s1, right: s2)
        XCTAssertEqual(2, d)
        
        let p = subject.findPath(s1, right: s2)
        print(p)

        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
