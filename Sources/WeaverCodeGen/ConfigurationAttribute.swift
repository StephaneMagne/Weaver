//
//  ConfigurationAttribute.swift
//  WeaverCodeGen
//
//  Created by Théophane Rupin on 5/13/18.
//

import Foundation

// MARK: - Attributes

public enum ConfigurationAttributeName: String {
    case isIsolated
    case customBuilder = "builder"
    case scope
    case doesSupportObjc = "objc"
    case setter
    case escaping
    case platforms
    case projects
}

public enum ConfigurationAttribute: Hashable {
    case isIsolated(value: Bool)
    case customBuilder(value: String)
    case scope(value: Scope)
    case doesSupportObjc(value: Bool)
    case setter(value: Bool)
    case escaping(value: Bool)
    case platforms(values: [Platform])
    case projects(values: [String])
}

// MARK: - Target

public enum ConfigurationAttributeTarget: Hashable {
    case `self`
    case dependency(name: String)
}

// MARK: - DependencyKind

enum ConfigurationAttributeDependencyKind {
    case reference
    case registration
    case parameter
}

// MARK: - Description

extension ConfigurationAttribute: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .isIsolated(let value):
            return "Config Attr - isIsolated = \(value)"
        case .customBuilder(let value):
            return "Config Attr - builder = \(value)"
        case .scope(let value):
            return "Config Attr - scope = \(value)"
        case .doesSupportObjc(let value):
            return "Config Attr - objc = \(value)"
        case .setter(let value):
            return "Config Attr - setter = \(value)"
        case .escaping(let value):
            return "Config Attr - escaping = \(value)"
        case .platforms(let values):
            return "Config Attr - platforms = [\(values.map { ".\($0.rawValue)" }.joined(separator: ", "))]"
        case .projects(let values):
            return "Config Attr - Projects = [\(values.joined(separator: ", "))]"
        }
    }
    
    var name: ConfigurationAttributeName {
        switch self {
        case .isIsolated:
            return .isIsolated
        case .customBuilder:
            return .customBuilder
        case .scope:
            return .scope
        case .doesSupportObjc:
            return .doesSupportObjc
        case .setter:
            return .setter
        case .escaping:
            return .escaping
        case .platforms:
            return .platforms
        case .projects:
            return .projects
        }
    }
}

extension ConfigurationAttributeTarget: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .`self`:
            return "self"
        case .dependency(let name):
            return name
        }
    }
}

// MARK: - Lexer Validation

extension ConfigurationAnnotation {
    
    static func validate(configurationAttribute: ConfigurationAttribute, with target: ConfigurationAttributeTarget) -> Bool {
        switch (configurationAttribute, target) {
        case (.isIsolated, .`self`),
             (.customBuilder, .dependency),
             (.scope, .dependency),
             (.doesSupportObjc, .dependency),
             (.setter, .dependency),
             (.escaping, .dependency),
             (.platforms, .dependency),
             (.projects, .dependency):
            return true
            
        case (.isIsolated, _),
             (.customBuilder, _),
             (.scope, _),
             (.doesSupportObjc, _),
             (.setter, _),
             (.escaping, _),
             (.platforms, _),
             (.projects, _):
            return false
        }
    }
}

// MARK: - Parser Validation

extension ConfigurationAnnotation {
    
    static func validate(configurationAttribute: ConfigurationAttribute, with dependencyKind: ConfigurationAttributeDependencyKind) -> Bool {
        switch (configurationAttribute, dependencyKind) {
        case (.scope, .registration),
             (.scope(.weak), .parameter),
             (.scope(.container), .parameter),
             (.customBuilder, .reference),
             (.customBuilder, .registration),
             (.setter, .registration),
             (.doesSupportObjc, .registration),
             (.escaping, .parameter),
             (.platforms, _),
             (.projects, _):
            return true
        case (.isIsolated, _),
             (.scope, _),
             (.setter, _),
             (.doesSupportObjc, _),
             (.escaping, _),
             (.customBuilder, _):
            return false
        }
    }
}

// MARK: - Builders

extension ConfigurationAttribute {
    
    init(name: String, valueString: String) throws {
        switch ConfigurationAttributeName(rawValue: name) {
        case .isIsolated:
            self = .isIsolated(value: try ConfigurationAttribute.boolValue(from: valueString))
        case .customBuilder:
            self = .customBuilder(value: valueString)
        case .scope:
            self = .scope(value: try ConfigurationAttribute.scopeValue(from: valueString))
        case .doesSupportObjc:
            self = .doesSupportObjc(value: try ConfigurationAttribute.boolValue(from: valueString))
        case .setter:
            self = .setter(value: try ConfigurationAttribute.boolValue(from: valueString))
        case .escaping:
            self = .escaping(value: try ConfigurationAttribute.boolValue(from: valueString))
        case .platforms:
            self = .platforms(values: try ConfigurationAttribute.platformValues(from: valueString))
        case .projects:
            self = .projects(values: try ConfigurationAttribute.projectValues(from: valueString))
        case .none:
            throw TokenError.unknownConfigurationAttribute(name: name)
        }
    }
    
    private static func boolValue(from string: String) throws -> Bool {
        guard let value = Bool(string) else {
            throw TokenError.invalidConfigurationAttributeValue(value: string, expected: "true|false")
        }
        return value
    }
    
    private static func scopeValue(from string: String) throws -> Scope {
        guard string.first == ".", let value = Scope(rawValue: string.replacingOccurrences(of: ".", with: "")) else {
            let expected = Scope.allCases.map { $0.rawValue }.joined(separator: "|")
            throw TokenError.invalidConfigurationAttributeValue(value: string, expected: expected)
        }
        return value
    }
    
    private static func platformValues(from string: String) throws -> [Platform] {
        var parsedString = string.trimmingTrailingCharacters(in: .whitespaces)
        guard parsedString.first == "[" && parsedString.last == "]" else {
            throw TokenError.invalidConfigurationAttributeValue(value: parsedString, expected: "Array of platforms (eg: `[.iOS, .watchOS, ...]`)")
        }
        parsedString.removeFirst()
        parsedString.removeLast()
        
        return try parsedString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .map {
                guard $0.first == ".", let platform = Platform(rawValue: $0.replacingOccurrences(of: ".", with: "")) else {
                    let expected = Platform.allCases.map { $0.rawValue }.joined(separator: "|")
                    throw TokenError.invalidConfigurationAttributeValue(value: $0, expected: expected)
                }
                return platform
            }
    }

    private static func projectValues(from string: String) throws -> [String] {
        var parsedString = string.trimmingTrailingCharacters(in: .whitespaces)
        guard parsedString.first == "[" && parsedString.last == "]" else {
            throw TokenError.invalidConfigurationAttributeValue(value: parsedString, expected: "Array of projects (eg: `[Calculator, Photos, ...]`)")
        }
        parsedString.removeFirst()
        parsedString.removeLast()

        return parsedString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .punctuationCharacters) }
    }
}

extension ConfigurationAttributeTarget {
    
    init(_ string: String) {
        switch string {
        case "self":
            self = .`self`
        case let name:
            self = .dependency(name: name)
        }
    }
}

// MARK: - Value

extension ConfigurationAttribute {

    var boolValue: Bool? {
        switch self {
        case .isIsolated(let value),
             .doesSupportObjc(let value),
             .setter(let value),
             .escaping(let value):
            return value

        case .scope,
             .customBuilder,
             .platforms,
             .projects:
            return nil
        }
    }
    
    var scopeValue: Scope? {
        switch self {
        case .scope(let value):
            return value
            
        case .customBuilder,
             .isIsolated,
             .doesSupportObjc,
             .setter,
             .escaping,
             .platforms,
             .projects:
            return nil
        }
    }
    
    var stringValue: String? {
        switch self {
        case .customBuilder(let value):
            return value
            
        case .scope,
             .isIsolated,
             .doesSupportObjc,
             .setter,
             .escaping,
             .platforms,
             .projects:
            return nil
        }
    }
    
    var platformValues: [Platform]? {
        switch self {
        case .platforms(let values):
            return values

        case .scope,
             .customBuilder,
             .isIsolated,
             .setter,
             .escaping,
             .doesSupportObjc,
             .projects:
            return nil
        }
    }

    var projectValues: [String]? {
        switch self {
        case .projects(let values):
            return values

        case .scope,
             .customBuilder,
             .isIsolated,
             .setter,
             .escaping,
             .doesSupportObjc,
             .platforms:
            return nil
        }
    }
}
