//
//  Parser.swift
//  BeaverDICodeGen
//
//  Created by Théophane Rupin on 2/28/18.
//

import Foundation

public final class Parser {
    
    private let tokens: [AnyTokenBox]
    private let fileName: String

    private var index = 0
    
    public init(_ tokens: [AnyTokenBox], fileName: String) {
        self.tokens = tokens
        self.fileName = fileName
    }
    
    public func parse() throws -> Expr {
        return try parseFile()
    }
}

// MARK: - Utils

private extension Parser {
    
    var currentToken: AnyTokenBox? {
        return index < tokens.count ? tokens[index] : nil
    }
    
    func consumeToken(n: Int = 1) {
        index += n
    }
}

// MARK: - Parsing

private extension Parser {
    
    func parseAnyDeclarations() {
        while true {
            switch currentToken {
            case is TokenBox<EndOfAnyDeclaration>:
                consumeToken()
            case is TokenBox<AnyDeclaration>:
                consumeToken()
            default:
                return
            }
        }
    }

    func parseRegisterAnnotation() throws -> TokenBox<RegisterAnnotation> {
        switch currentToken {
        case let token as TokenBox<RegisterAnnotation>:
            consumeToken()
            return token
        case nil:
            throw ParserError.unexpectedEOF(file: fileName)
        case .some(let token):
            throw ParserError.unexpectedToken(line: token.line, file: fileName)
        }
    }
    
    func parseReferenceAnnotation() throws -> TokenBox<ReferenceAnnotation> {
        switch currentToken {
        case let token as TokenBox<ReferenceAnnotation>:
            consumeToken()
            return token
        case nil:
            throw ParserError.unexpectedEOF(file: fileName)
        case .some(let token):
            throw ParserError.unexpectedToken(line: token.line, file: fileName)
        }
    }
    
    func parseScopeAnnotation() throws -> TokenBox<ScopeAnnotation> {
        switch currentToken {
        case let token as TokenBox<ScopeAnnotation>:
            consumeToken()
            return token
        case nil:
            throw ParserError.unexpectedEOF(file: fileName)
        case .some(let token):
            throw ParserError.unexpectedToken(line: token.line, file: fileName)
        }
    }
    
    func parseInjectableType() throws -> TokenBox<InjectableType> {
        switch currentToken {
        case let token as TokenBox<InjectableType>:
            consumeToken()
            return token
        case nil:
            throw ParserError.unexpectedEOF(file: fileName)
        case .some(let token):
            throw ParserError.unexpectedToken(line: token.line, file: fileName)
        }
    }
    
    func parseInjectedTypeDeclaration() throws -> Expr? {
        let type = try parseInjectableType()
        
        var children = [Expr]()
        var registrationNames = Set<String>()
        var referenceNames = Set<String>()
        
        while true {
            parseAnyDeclarations()

            switch currentToken {
            case is TokenBox<RegisterAnnotation>:
                let annotation = try parseRegisterAnnotation()
                let name = annotation.value.name
                guard !registrationNames.contains(name) && !referenceNames.contains(name) else {
                    throw ParserError.depedencyDoubleDeclaration(line: annotation.line, file: fileName, dependencyName: name)
                }
                registrationNames.insert(name)
                children.append(.registerAnnotation(annotation))
            
            case is TokenBox<ReferenceAnnotation>:
                let annotation = try parseReferenceAnnotation()
                let name = annotation.value.name
                guard !registrationNames.contains(name) && !referenceNames.contains(name) else {
                    throw ParserError.depedencyDoubleDeclaration(line: annotation.line, file: fileName, dependencyName: name)
                }
                referenceNames.insert(name)
                children.append(.referenceAnnotation(annotation))

            case is TokenBox<ScopeAnnotation>:
                let annotation = try parseScopeAnnotation()
                guard registrationNames.contains(annotation.value.name) else {
                    throw ParserError.unknownDependency(line: annotation.line, file: fileName, dependencyName: annotation.value.name)
                }
                children.append(.scopeAnnotation(annotation))
            
            case is TokenBox<InjectableType>:
                if let typeDeclaration = try parseInjectedTypeDeclaration() {
                    children.append(typeDeclaration)
                }
            
            case is TokenBox<EndOfInjectableType>:
                consumeToken()
                if children.isEmpty {
                    return nil
                } else {
                    return .typeDeclaration(type, children: children)
                }

            case nil:
                throw ParserError.unexpectedEOF(file: fileName)
            
            case .some(let token):
                throw ParserError.unexpectedToken(line: token.line, file: fileName)
            }
        }
    }
    
    func parseFile() throws -> Expr {
        
        var types = [Expr]()
        
        while true {
            parseAnyDeclarations()

            switch currentToken {
            case is TokenBox<InjectableType>:
                if let typeDeclaration = try parseInjectedTypeDeclaration() {
                    types.append(typeDeclaration)
                }
                
            case is TokenBox<EndOfInjectableType>:
                consumeToken()

            case nil:
                return .file(types: types, name: fileName)
                
            case .some(let token):
                throw ParserError.unexpectedToken(line: token.line, file: fileName)
            }
        }
    }
}
