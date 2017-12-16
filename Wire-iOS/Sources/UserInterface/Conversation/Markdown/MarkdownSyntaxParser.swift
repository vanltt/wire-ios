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

class MarkdownSyntaxParser {
    
    var style: MarkdownStyle
    
    init(style: MarkdownStyle) {
        self.style = style
    }
    
    private lazy var matchers: [Matcher] = {
        var result = [Matcher]()
        
        var attrs = self.style.attributes(for: .header1)
        result.append(Matcher(markdown: .header1, pattern: header1Pattern, options: .anchorsMatchLines, attributes: attrs))
        
        attrs = self.style.attributes(for: .header2)
        result.append(Matcher(markdown: .header2, pattern: header2Pattern, options: .anchorsMatchLines, attributes: attrs))
        
        attrs = self.style.attributes(for: .header3)
        result.append(Matcher(markdown: .header3, pattern: header3Pattern, options: .anchorsMatchLines, attributes: attrs))
        
        attrs = self.style.attributes(for: .bold)
        result.append(Matcher(markdown: .bold, pattern: boldPattern, options: .dotMatchesLineSeparators, attributes: attrs))
        
        attrs = self.style.attributes(for: .italic)
        result.append(Matcher(markdown: .italic, pattern: italicPattern, options: .dotMatchesLineSeparators, attributes: attrs))
        
        return result 
    }()
    
    /// Returns an attributed string constructed by the given syntax string.
    ///
    func parse(_ syntaxString: String) -> NSAttributedString {
        return NSAttributedString(string: "")
    }
}

private class Matcher {
    
    let markdown: Markdown
    let regex: NSRegularExpression
    let attributes: Attributes
    
    init(markdown: Markdown, pattern: String, options: NSRegularExpression.Options, attributes: Attributes) {
        self.markdown = markdown
        self.attributes = attributes
        
        do {
            try self.regex = NSRegularExpression(pattern: pattern, options: options)
        } catch let error {
            fatal("Could not create Regular Expression: \(error.localizedDescription)")
        }
    }
}

private let header1Pattern = "(^\\#{1}[\\t ]+)(.*)$"
private let header2Pattern = "(^\\#{2}[\\t ]+)(.*)$"
private let header3Pattern = "(^\\#{3}[\\t ]+)(.*)$"
private let boldPattern = "(\\*{2})(.+)(\\1)"
private let italicPattern = "(\\_)(.+)(\\1)"
