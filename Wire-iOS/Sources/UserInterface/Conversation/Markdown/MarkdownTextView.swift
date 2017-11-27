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


import UIKit

extension Notification.Name {
    static let MarkdownTextViewDidChangeSelection = Notification.Name("MarkdownTextViewDidChangeSelection")
    static let MarkdownTextViewDidChangeActiveMarkdown = Notification.Name("MarkdownTextViewDidChangeActiveMarkdown")
}

public class MarkdownTextView: NextResponderTextView {
    
    /// Handles conversion between markdown syntax & attributed strings.
    ///
    let parser = MarkdownParser()
    
    /// Provides the typing attributes associated with the markdown types.
    ///
    var style = MarkdownStyle()
    
    /// The currently activated markdown. This determines the current typing
    /// attribtues.
    ///
    var activeMarkdown: Markdown = .none {
        didSet {
            if oldValue != activeMarkdown {
                NotificationCenter.default.post(name: .MarkdownTextViewDidChangeActiveMarkdown, object: self)
            }
        }
    }
    
    /// The converted string containing markdown syntax.
    ///
    var parsedText: String {
        return parser.parse(attributedString: attributedText)
    }
    
    /// The range of the whole attributed text.
    ///
    private var wholeRange: NSRange {
        return NSMakeRange(0, attributedText.length)
    }
    
    public override var selectedTextRange: UITextRange? {
        didSet {
            activeMarkdown = self.markdownAtCaret()
            NotificationCenter.default.post(name: .MarkdownTextViewDidChangeSelection, object: self)
        }
    }
    
    // MARK: - Querying Markdown Types
    
    /// Returns the markdown bitmask at the current caret position.
    ///
    func markdownAtCaret() -> Markdown {
        return markdown(at: selectedRange.location)
    }
    
    /// Returns the markdown bitmask at the given location if it exists, else
    /// returns the `none` bitmask.
    ///
    func markdown(at location: Int) -> Markdown {
        guard location >= 0 && attributedText.length > location else { return .none }
        let type = attributedText.attribute(MarkdownAttributeName, at: location, effectiveRange: nil) as? Markdown
        return type ?? .none
    }
    
    /// Returns a dictionary containing the subranges for each markdown type
    /// where this markdown is present in the given range.
    ///
    func markdown(in range: NSRange) -> [Markdown: [NSRange]] {
        guard wholeRange.contains(range) else { return [:] }
        
        var result = [Markdown: [NSRange]]()
        
        // determine ranges for each markdown element
        attributedText.enumerateAttribute(MarkdownAttributeName, in: range, options: []) { (value, attrRange, _) in
            let markdown = (value as? Markdown) ?? .none
            result[markdown, default: []].append(attrRange)
        }
        
        // since we reset typing attributes at each change, the length of the ranges
        // corresponds to the length of the last edit. This results in numerous
        // ranges that are adjacent to each other. We want to combine these together.
        return result.mapValues { return $0.unified }
    }
    
    // MARK: - Applying Markdown
    
    // NOTE: this is a workaround. The typingAttributes is cleared each time the
    // text changes, and there is no defaultAttributes property, so we have to
    // make sure the typingAttributes is reset after every change.
    ///
    func updateTypingAttributes() {
        typingAttributes = self.style.attributes(for: activeMarkdown) as [String : Any]
    }
    
    /// Resets the text view by emptying the string buffer & clearing the
    /// active markdown.
    ///
    func reset() {
        text = ""
        activeMarkdown = .none
    }
    
}

// MARK: - Markdown Bar Delegate

extension MarkdownTextView: MarkdownBarViewDelegate {
    
    func markdownBarView(_ markdownBarView: MarkdownBarView, didSelectMarkdown markdown: Markdown, with sender: IconButton) {
        let combined = activeMarkdown.union(markdown)
        activeMarkdown = combined.isValid ? combined : markdown
    }
    
    func markdownBarView(_ markdownBarView: MarkdownBarView, didDeselectMarkdown markdown: Markdown, with sender: IconButton) {
        activeMarkdown.subtract(markdown)
    }
}

// MARK: - Helper Extensions

fileprivate extension NSRange {
    
    /// Returns true iff the given range is entirely contained within self.
    ///
    func contains(_ range: NSRange) -> Bool {
        guard let intersection = self.intersection(range) else { return false }
        return NSEqualRanges(intersection, range)
    }
}

fileprivate extension Array where Iterator.Element == NSRange  {
    
    /// Returns a copy of the array where adjacent ranges (ones that have no
    /// gaps between them) are unified. Eg. [{0,1},{1,2},{4,1}] -> [{0,3},{4,1}]
    ///
    var unified: [NSRange] {
        let sorted = self.sorted { return $0.location <= $1.location }
        
        return sorted.reduce(into: [], { (acc: inout [NSRange], nextRange) in
            if acc.isEmpty {
                return acc.append(nextRange)
            } else {
                let last = acc.popLast()!
                // if adjacent
                if NSMaxRange(last) >= nextRange.lowerBound {
                    return acc.append(NSUnionRange(last, nextRange))
                } else {
                    return acc.append(contentsOf: [last, nextRange])
                }
            }
        })
    }
}

