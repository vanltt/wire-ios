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


import Foundation

/// This class is repsonsible for the conversion between text containing
/// style attributes and text containing markdown syntax.
///
class MarkdownParser {
    
    typealias Syntax = (prefix: String, suffix: String)
    
    /// The style used to apply markdown attributes.
    ///
    var style = MarkdownStyle()
    
    /// The parser used to convert attributed strings to syntax strings.
    ///
    private lazy var attributeParser: MarkdownAttributeParser = {
       return MarkdownAttributeParser(syntaxMap: self.syntaxMap)
    }()
    
    /// The parser used to convert syntax strings to attributed strings.
    ///
    private lazy var syntaxParser: MarkdownSyntaxParser = {
        return MarkdownSyntaxParser(syntaxMap: self.syntaxMap)
    }()
    
    /// The mapping between markdown types and their corresponding syntax.
    ///
    private let syntaxMap: [Markdown : Syntax] = [
        .none:          Syntax(prefix: "", suffix: ""),
        .header1:       Syntax(prefix: "# ", suffix: ""),
        .header2:       Syntax(prefix: "## ", suffix: ""),
        .header3:       Syntax(prefix: "### ", suffix: ""),
        .bold:          Syntax(prefix: "**", suffix: "**"),
        .italic:        Syntax(prefix: "_", suffix: "_"),
        .boldItalic:    Syntax(prefix:"**_", suffix: "_**"),
        .code:          Syntax(prefix: "`", suffix: "`"),
    ]
    
    /// Returns a string formatted with markdown syntax converted from the
    /// given attributed string.
    ///
    func parse(attributedString: NSAttributedString) -> String {
        return attributeParser.parse(attributedString)
    }
    
    /// Returns an attributed string constructed by the given syntax string.
    ///
    func parse(syntaxString: String) -> NSAttributedString {
        return syntaxParser.parse(syntaxString)
    }
}
