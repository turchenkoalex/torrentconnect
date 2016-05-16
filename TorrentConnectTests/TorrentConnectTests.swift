//
//  TorrentConnectTests.swift
//  TorrentConnectTests
//
//  Created by Александр Турченко on 20.08.15.
//  Copyright © 2015 Turchenko Alexander. All rights reserved.
//

import XCTest
@testable import TorrentConnect

class TorrentConnectTests: XCTestCase {
    
    var subject: Sections<Int> = Sections(sections: [])
    
    override func setUp() {
        super.setUp()
        
        let items = [
            Section(title: "1", collapsed: false, elements: [1,2]),
            Section(title: "2", collapsed: false, elements: [1,2,3]),
            Section(title: "3", collapsed: true, elements: [1,2,3]),
            Section(title: "4", collapsed: false, elements: [1])]
        
        subject = Sections(sections: items)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPositionAt() {
        
        assertPosition(subject.positionAt(0), section: 0, element: 0)
        assertPosition(subject.positionAt(1), section: 0, element: 1)
        assertPosition(subject.positionAt(2), section: 0, element: 2)
        
        assertPosition(subject.positionAt(3), section: 1, element: 0)
        assertPosition(subject.positionAt(4), section: 1, element: 1)
        assertPosition(subject.positionAt(5), section: 1, element: 2)
        assertPosition(subject.positionAt(6), section: 1, element: 3)
        
        assertPosition(subject.positionAt(7), section: 2, element: 0)
        
        assertPosition(subject.positionAt(8), section: 3, element: 0)
        assertPosition(subject.positionAt(9), section: 3, element: 1)
        
        XCTAssertNil(subject.positionAt(-1))
        XCTAssertNil(subject.positionAt(10))
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testIsGroup() {
        
        XCTAssertTrue(subject.isGroup(0))
        XCTAssertFalse(subject.isGroup(1))
        XCTAssertFalse(subject.isGroup(2))
        
        XCTAssertTrue(subject.isGroup(3))
        XCTAssertFalse(subject.isGroup(4))
        XCTAssertFalse(subject.isGroup(5))
        XCTAssertFalse(subject.isGroup(6))
        
        XCTAssertTrue(subject.isGroup(7))
        XCTAssertTrue(subject.isGroup(8))
        
        XCTAssertFalse(subject.isGroup(9))
        
        XCTAssertFalse(subject.isGroup(-1))
        XCTAssertFalse(subject.isGroup(10))
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func assertPosition(pos: (section: Int, element: Int)?, section: Int, element: Int) {
        if let pos0 = pos {
            XCTAssertEqual(pos0.section, section)
            XCTAssertEqual(pos0.element, element)
        } else {
            XCTAssertTrue(false, "Wrong position")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
