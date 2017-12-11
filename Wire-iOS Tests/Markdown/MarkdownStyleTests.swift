//
// Wire
// Copyright (C) 2017 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import XCTest
@testable import Wire

class MarkdownStyleTests: XCTestCase {
    
    let sut = MarkdownStyle()
    
    // MARK: - Getting Attributes
    
    func testThatItReturnsCorrectAttributes() {
        
        let result: (Markdown) -> NSDictionary = {
            return NSDictionary(dictionary: self.sut.attributes(for: $0))
        }
    
        XCTAssertEqual(result(.none),       NSDictionary(dictionary: sut.defaultAttributes))
        XCTAssertEqual(result(.header1),    NSDictionary(dictionary: sut.header1Attributes))
        XCTAssertEqual(result(.header2),    NSDictionary(dictionary: sut.header2Attributes))
        XCTAssertEqual(result(.header3),    NSDictionary(dictionary: sut.header3Attributes))
        XCTAssertEqual(result(.bold),       NSDictionary(dictionary: sut.boldAttributes))
        XCTAssertEqual(result(.italic),     NSDictionary(dictionary: sut.italicAttributes))
        XCTAssertEqual(result(.boldItalic), NSDictionary(dictionary: sut.boldItalicAttributes))
        XCTAssertEqual(result(.code),       NSDictionary(dictionary: sut.codeAttributes))
    }
}
