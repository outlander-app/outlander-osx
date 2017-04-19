//
//  Combinators.swift
//  Outlander
//
//  Created by Joseph McBride on 3/28/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

public struct Parser<A> {
    public typealias Stream = String.CharacterView
    let parse: (Stream) -> (A, Stream)?
}

extension Parser {
    public func run(_ x: String) -> (A, Stream)? {
        return parse(x.characters)
    }

    public func res<Result>(_ res:Result) -> Parser<Result> {
        return Parser<Result> { stream in
            guard let (_, newStream) = self.parse(stream) else { return nil }
            return (res, newStream)
        }
    }

    public func map<Result>(_ f: @escaping (A) -> Result) -> Parser<Result> {
        return Parser<Result> { stream in
            guard let (result, newStream) = self.parse(stream) else { return nil }
            return (f(result), newStream)
        }
    }

    public func flatMap<Result>(_ f: @escaping (A) -> Parser<Result>) -> Parser<Result> {
        return Parser<Result> { stream in
            guard let (result, newStream) = self.parse(stream) else { return nil }
            return f(result).parse(newStream)
        }
    }

    public var many: Parser<[A]> {
        return Parser<[A]> { stream in
            var result: [A] = []
            var remainder = stream
            while let (element, newRemainder) = self.parse(remainder) {
                remainder = newRemainder
                result.append(element)
            }
            return (result, remainder)
        }
    }

    public var oneOrMore: Parser<[A]> {
        return Parser<[A]> { stream in

            guard let (first, firstRemainder) = self.parse(stream) else { return nil }

            var result: [A] = [first]
            var remainder = firstRemainder

            while let (element, newRemainder) = self.parse(remainder) {
                remainder = newRemainder
                result.append(element)
            }
            return (result, remainder)
        }
    }

    public func or(_ other: Parser<A>) -> Parser<A> {
        return Parser { stream in
            return self.parse(stream) ?? other.parse(stream)
        }
    }

    public func followed<B, C>(by other: Parser<B>, combine: @escaping (A, B) -> C) -> Parser<C> {
        return Parser<C> { stream in
            guard let (result, remainder) = self.parse(stream) else { return nil }
            guard let (result2, remainder2) = other.parse(remainder) else { return nil }
            return (combine(result,result2), remainder2)
        }
    }

    public func followed<B>(by other: Parser<B>) -> Parser<(A, B)> {
        return followed(by: other, combine: { ($0, $1) })
    }

    public init(result: A) {
        parse = { stream in (result, stream) }
    }

    public var optional: Parser<A?> {
        return self.map({ .some($0) }).or(Parser<A?>(result: nil))
    }
}

public func unescape(_ value: String, _ what: Character) -> String {
    let slash = "\\"
    return ([slash] + [String(what)]).reduce(value) {
        return $0.replace(slash + $1, withString: $1)
    }
}

public func block(_ start:Character, _ end:Character) -> Parser<String> {
    let startBlock = char(start)
    let endBlock = char(end)
    let escapedEnd = "\\" + String(end)
    let escaped = (string(escapedEnd) *> Parser(result: escapedEnd)) <|> not(end).map { String($0) }
    let block = startBlock *> escaped.many.map { $0.joined() } <* endBlock
    return block
}

public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { x in { y in f(x, y) } }
}

func curry<A, B, C, R>(_ f: @escaping (A, B, C) -> R) -> (A) -> (B) -> (C) -> R {
    return { a in { b in { c in f(a, b, c) } } }
}

public func character(condition: @escaping (Character) -> Bool) -> Parser<Character> {
    return Parser { stream in
        guard let char = stream.first, condition(char) else { return nil }
        return (char, stream.dropFirst())
    }
}

public func not(_ c:Character) -> Parser<Character> {
    return character(condition: { $0 != c })
}

public func char(_ c:Character) -> Parser<Character> {
    return character(condition: { $0 == c })
}

public func string(_ string: String) -> Parser<String> {
    return Parser<String> { stream in
        var remainder = stream
        
        for char in string.characters {
            guard let (_, newRemainder) = character(condition: { $0 == char }).parse(remainder) else {
                return nil
            }
            remainder = newRemainder
        }
        return (string, remainder)
    }
}

public func stringInSensitive(_ string: String) -> Parser<String> {
    return Parser<String> { stream in
        var remainder = stream
        
        for char in string.characters {
            guard let (_, newRemainder) = character(condition: { $0 == char.lowercase || $0 == char.uppercase }).parse(remainder) else {
                return nil
            }
            remainder = newRemainder
        }
        return (string, remainder)
    }
}

public func anyOf(_ list:[String]) -> Parser<String> {
    return Parser<String> { stream in
        for item in list {
            if let (res, remainder) = stringInSensitive(item).parse(stream) {
                return (res, remainder)
            }
        }
        return ("", stream)
    }
}

public func noneOf(_ list: [Character]) -> Parser<String> {
    return Parser<String> { stream in
        var result: [Character] = []
        var remainder = stream

        while let (element, newRemainder) = character(condition: { !list.contains($0) }).parse(remainder) {
            remainder = newRemainder
            result.append(element)
        }

        return (String(result), remainder)
    }
}

public func noneOf(_ strings:[String]) -> Parser<String> {
    let strings = strings.map { ($0, $0.characters.map { $0.uppercase }) }
    return Parser { stream in

        guard let _ = stream.first else {
            return ("", stream)
        }

        var count = 0

        for next in stream {
            for (_, characters) in strings {
                guard characters.first == next.uppercase else { continue }
                let offset = characters.count
                guard stream.count >= offset + count else { continue }

                let startIndex = stream.index(stream.startIndex, offsetBy: count)
                let endIndex = stream.index(stream.startIndex, offsetBy: offset + count)

                guard endIndex <= stream.endIndex else { continue }
                let peek = stream[startIndex..<endIndex].map { $0.uppercase }

                if characters.elementsEqual(peek) {
                    let res = String(stream[stream.startIndex..<startIndex])
                    let remainder = stream.dropFirst(count)
                    return (res, remainder)
                }
            }

            count += 1
        }

        return (String(stream), String("")!.characters)
    }
}

// Delay creation of parser until it is needed
public func lazy <T> (_ f: @autoclosure @escaping () -> Parser<T>) -> Parser<T> {
    return Parser { input in f().parse(input) }
}

precedencegroup ApplyGroup {
    associativity: right
    higherThan: ComparisonPrecedence
}

precedencegroup SequencePrecedence {
    associativity: left
    higherThan: ApplyGroup
}

infix operator <^> : SequencePrecedence
infix operator <^^> : SequencePrecedence
infix operator <*> : SequencePrecedence
infix operator <&> : SequencePrecedence
infix operator *> : SequencePrecedence
infix operator <* : SequencePrecedence
infix operator <|> : ApplyGroup
infix operator >>- : SequencePrecedence

public func <^^><A, B>(f: B, rhs: Parser<A>) -> Parser<B> {
    return rhs.res(f)
}

public func <^><A, B>(f: @escaping (A) -> B, rhs: Parser<A>) -> Parser<B> {
    return rhs.map(f)
}

public func <^><A, B, R>(f: @escaping (A, B) -> R, rhs: Parser<A>) -> Parser<(B) -> R> {
    return Parser(result: curry(f)) <*> rhs
}

public func <*><A, B>(lhs: Parser<(A) -> B>, rhs: Parser<A>) -> Parser<B> {
    return lhs.followed(by: rhs, combine: { $0($1) })
}

public func <&><A, B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<(A,B)> {
    return lhs.followed(by: rhs, combine: { ($0, $1) })
}

public func <*<A, B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<A> {
    return lhs.followed(by: rhs, combine: { x, _ in x })
}

public func *><A, B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<B> {
    return lhs.followed(by: rhs, combine: { _, x in x })
}

public func <|><A>(lhs: Parser<A>, rhs: Parser<A>) -> Parser<A> {
    return lhs.or(rhs)
}

public func >>-<A, R>(lhs: Parser<A>, rhs: @escaping (A)->Parser<R>) -> Parser<R> {
    return lhs.flatMap(rhs)
}
