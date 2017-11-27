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
    
    /// The style used to apply markdown attributes
    ///
    var style = MarkdownStyle()
    
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
        
        var stack = [Markdown]()
        var result = ""
        
        let push: (Markdown, String) -> Void = { markdown, content in
            stack.append(markdown)
            result += self.syntaxMap[markdown]?.prefix ?? ""
            result += content
        }
        
        let pop: () -> Void = {
            guard let last = stack.popLast() else { return }
            
            // TODO: need to check if it's a header, only insert newline if
            // one doesn't already exist.
            
            result += self.syntaxMap[last]?.suffix ?? ""
        }
        
        // Algorithm:
        // 1. If stack is empty, push MD & append string. DONE
        // 2. If current MD is exactly same as combined stack, append string. DONE
        // 3. If current MD is disjoint from combined stack, pop, repeat.
        // 4. Not disjoint. Calculate unique MD in current (compared to combined stack),
        //      -> If no unique MD, pop, repeat.
        //      -> else push unique. DONE
        //
        let process: (Markdown, String) -> Void = { markdown, contentString in
            
            var done = false
            
            while !done {
                
                guard !stack.isEmpty else {
                    // 1
                    push(markdown, contentString)
                    return
                }
                
                // combined MD in the stack
                let combined = stack.reduce(Markdown.none) { return $0.union($1) }
                
                if markdown == combined {
                    // 2
                    result += contentString
                    done = true
                }
                else if combined.isDisjoint(with: markdown) {
                    // 3
                    pop()
                    continue
                }
                else {
                    // 4
                    let uniqueMarkdown = markdown.subtracting(combined)
                    
                    if uniqueMarkdown == .none {
                        pop()
                        continue
                    }
                    else {
                        push(uniqueMarkdown, contentString)
                        done = true
                    }
                }
            }
        }
        
        attributedString.enumerateAttribute(MarkdownAttributeName, in: NSMakeRange(0, attributedString.length), options: []) { (value, range, _) in
            
            let markdown = (value as? Markdown) ?? .none
            let contentString =  attributedString.attributedSubstring(from: range).string
            process(markdown, contentString)
        }
        
        // add any remaining suffix syntax
        while let markdown = stack.popLast() {
            result += self.syntaxMap[markdown]?.suffix ?? ""
        }
        
        return result
    }
    
    /// Returns an attributed string constructed by the given markdown string.
    ///
    func parse(markdownString: String) -> NSAttributedString {
        return NSAttributedString(string: "")
    }
}
