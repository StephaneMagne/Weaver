//
//  Error.swift
//  WeaverCodeGen
//
//  Created by Théophane Rupin on 3/7/18.
//

import Foundation

enum TokenError: Error {
    case invalidAnnotation(String)
    case invalidScope(String)
    case invalidConfigurationAttributeValue(value: String, expected: String)
    case invalidConfigurationAttributeTarget(name: String, target: ConfigurationAttributeTarget)
    case unknownConfigurationAttribute(name: String)
}

enum LexerError: Error {
    case invalidAnnotation(FileLocation, underlyingError: TokenError)
}

enum ParserError: Error {
    case unexpectedToken(FileLocation)
    case unexpectedEOF(FileLocation)
    
    case unknownDependency(String, FileLocation)
    case dependencyDoubleDeclaration(String, FileLocation)
    case configurationAttributeDoubleAssignation(FileLocation, attribute: ConfigurationAttribute)
}

enum LinkerError: Error {
    case foundAnnotationOutsideOfType(FileLocation)
    case unknownType(FileLocation?, type: AnyType)
    case dependencyNotFound(FileLocation?, dependencyName: String)
}

enum DependencyGraphError: Error {
    case dependencyContainerNotFound(FileLocation?, type: AnyType?)
    case invalidAbstractTypeComposition(FileLocation?, types: Set<AbstractType>, candidates: [(String, ConcreteType)])
}

enum SwiftGeneratorError: Error {
    case dependencyContainersNotFoundForFileName(String)
    case dependencyContainerIsMissingTypeInFile(String)
    case dependencyContainerNotFoundForName(String)
    case missingProjectTargetName
}

enum InspectorError: Error {
    case invalidAST(FileLocation, unexpectedExpr: Expr)
    case invalidDependencyGraph(Dependency, underlyingError: InspectorAnalysisError)
    case invalidContainerScope(Dependency)
}

enum InspectorAnalysisError: Error {
    case cyclicDependency(history: [InspectorAnalysisHistoryRecord])
    case unresolvableDependency(history: [InspectorAnalysisHistoryRecord])
    case isolatedResolverCannotHaveReferents(type: AnyType?, referents: [DependencyContainer])
    case typeMismatch
}

enum InspectorAnalysisHistoryRecord: Error {
    case dependencyNotFound(Dependency, in: DependencyContainer)
    case triedToBuildType(DependencyContainer, stepCount: Int)
    case triedToResolveDependencyInType(Dependency, stepCount: Int)
    case triedToResolveDependencyInRootType(DependencyContainer)
    case typeMismatch(Dependency, candidate: Dependency)
    case implicitDependency(Dependency, candidates: [Dependency])
    case implicitType(Dependency, candidates: [Dependency])
}

// MARK: - Printables

protocol Printable {
    var fileLocation: FileLocation? { get }
}

protocol PrintableDependency: Printable {
    var dependencyName: String { get }
}

protocol PrintableDependencyContainer: Printable {
    var type: ConcreteType { get }
}

extension DependencyContainer: PrintableDependencyContainer {}
extension Dependency: PrintableDependency {}

struct FileLocation: Printable, Encodable {
    let line: Int?
    let file: String?
    
    init(line: Int? = nil,
         file: String? = nil) {
        self.line = line
        self.file = file
    }
    
    var fileLocation: FileLocation? {
        return self
    }
    
    static func file(_ file: String?) -> FileLocation {
        return FileLocation(line: nil, file: file)
    }
}

// MARK: - Description

extension TokenError: CustomStringConvertible {

    var description: String {
        switch self {
        case .invalidAnnotation(let annotation):
            return "Invalid annotation: '\(annotation)'"
        case .invalidScope(let scope):
            return "Invalid scope: '\(scope)'"
        case .invalidConfigurationAttributeValue(let value, let expected):
            return "Invalid configuration attribute value: '\(value)'. Expected '\(expected)'"
        case .invalidConfigurationAttributeTarget(let name, let target):
            return "Can't assign configuration attribute '\(name)' on '\(target)'"
        case .unknownConfigurationAttribute(let name):
            return "Unknown configuration attribute: '\(name)'"
        }
    }
}

extension LexerError: CustomStringConvertible {

    var description: String {
        switch self {
        case .invalidAnnotation(let location, let underlyingError):
            return location.xcodeLogString(.error, "\(underlyingError)")
        }
    }
}

extension ParserError: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .dependencyDoubleDeclaration(let dependencyName, let location):
            return location.xcodeLogString(.error, "Double dependency declaration: '\(dependencyName)'")
        case .unexpectedEOF(let location):
            return location.xcodeLogString(.error, "Unexpected EOF (End of file)")
        case .unexpectedToken(let location):
            return location.xcodeLogString(.error, "Unexpected token")
        case .unknownDependency(let dependencyName, let location):
            return location.xcodeLogString(.error, "Unknown dependency: '\(dependencyName)'")
        case .configurationAttributeDoubleAssignation(let location, let attribute):
            return location.xcodeLogString(.error, "Configuration attribute '\(attribute.name)' was already set")
        }
    }
}

extension DependencyGraphError: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .dependencyContainerNotFound(let location, let type):
            let message = "Could not find dependency container associated to type '\(type?.description ?? "_")'"
            if let location = location {
                return location.xcodeLogString(.error, message)
            } else {
                return message
            }
        case .invalidAbstractTypeComposition(let location, let types, let candidates):
            let message = "Invalid type composition: '\(types.lazy.map { $0.description }.sorted().joined(separator: " & "))'"
            let note = "Found candidates: '\(candidates.map { "\($0): \($1)" }.joined(separator: ", "))'"
            if let location = location {
                return [
                    location.xcodeLogString(.error, message),
                    candidates.isEmpty ? nil : location.xcodeLogString(.warning, note)
                ].compactMap { $0 }.joined(separator: "\n")
            } else {
                return [
                    message,
                    candidates.isEmpty ? nil : note
                ].compactMap { $0 }.joined(separator: "\n")
            }
        }
    }
}

extension SwiftGeneratorError: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .dependencyContainersNotFoundForFileName(let fileName):
            return "Could not find dependency graphs for file: '\(fileName)'."
        case .dependencyContainerIsMissingTypeInFile(let fileName):
            return "Could not resolve type for dependency container in file: '\(fileName)'."
        case .dependencyContainerNotFoundForName(let name):
            return "Could not find dependency container for name: '\(name)'."
        case .missingProjectTargetName:
            return "Project target name is missing."
        }
    }
}

extension InspectorError: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .invalidAST(let location, let token):
            return location.xcodeLogString(.error, "Invalid AST because of token: \(token)")
        case .invalidDependencyGraph(let dependency, let underlyingIssue):
            var description = dependency.xcodeLogString(.error, "Invalid dependency: '\(dependency.dependencyName): \(dependency.type)'. \(underlyingIssue)")
            if let notes = underlyingIssue.notes {
                description = ([description] + notes.map { $0.description }).joined(separator: "\n")
            }
            return description
        case .invalidContainerScope(let dependency):
            let message = "Dependency '\(dependency.dependencyName)' cannot declare parameters and be registered with a container scope"
            return dependency.fileLocation?.xcodeLogString(.error, message) ?? message
        }
    }
}

extension InspectorAnalysisError: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .cyclicDependency:
            return "Detected a cyclic dependency"
        case .unresolvableDependency:
            return "Dependency cannot be resolved"
        case .isolatedResolverCannotHaveReferents:
            return "This type is flagged as isolated. It cannot have any connected referent"
        case .typeMismatch:
            return "Type mismatch"
        }
    }
    
    fileprivate var notes: [CustomStringConvertible]? {
        switch self {
        case .cyclicDependency(let history),
             .unresolvableDependency(let history):
            return history
        case .isolatedResolverCannotHaveReferents(let type, let referents):
            return referents.map { referent in
                let message = "'\(referent.type)' " +
                    "cannot depend on '\(type?.description ?? "_")' because it is flagged as 'isolated'. " +
                    "You may want to set '\(type?.description ?? "_").isIsolated' to 'false'"
                return referent.xcodeLogString(.error, message)
            }
        case .typeMismatch:
            return nil
        }
    }
}

extension InspectorAnalysisHistoryRecord: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .dependencyNotFound(let dependency, let dependencyContainer):
            return dependencyContainer.xcodeLogString(.warning, "Could not find the dependency '\(dependency.dependencyName)' in '\(dependencyContainer.type)'. You may want to register it here to solve this issue")
        case .triedToBuildType(let dependencyContainer, let stepCount):
            return dependencyContainer.xcodeLogString(.warning, "Step \(stepCount): Tried to build type '\(dependencyContainer.type)'")
        case .triedToResolveDependencyInType(let dependency, let stepCount):
            return dependency.xcodeLogString(.warning, "Step \(stepCount): Tried to resolve dependency '\(dependency.dependencyName)' in type '\(dependency.source)'")
        case .triedToResolveDependencyInRootType(let dependencyContainer):
            return dependencyContainer.xcodeLogString(.warning, "Type '\(dependencyContainer.type)' doesn't seem to be attached to the dependency graph. You might have to use `self.isIsolated = true` or register it somewhere")
        case .typeMismatch(let dependency, let candidate):
            return """
            \(dependency.xcodeLogString(.error, "Dependency '\(dependency.dependencyName)' has a mismatching type '\(dependency.type)'"))
            \(candidate.xcodeLogString(.warning, "Found candidate '\(candidate.dependencyName): \(candidate.type)'"))
            """
        case .implicitDependency(let dependency, let candidates):
            return """
            \(dependency.xcodeLogString(.error, "Dependency '\(dependency.dependencyName)' is implicit."))
            \(candidates.map { candidate in
                candidate.xcodeLogString(.warning, "Found candidate '\(candidate.dependencyName)'")
            }.joined(separator: ".\n"))
            """
        case .implicitType(let dependency, let candidates):
            return """
            \(dependency.xcodeLogString(.error, "Dependency '\(dependency.dependencyName)' has an implicit type '\(dependency.type)'.")) You can desambiguate by using one of the candidate dependency names.
            \(candidates.map { candidate in
                candidate.xcodeLogString(.warning, "Found candidate '\(candidate.dependencyName): \(candidate.type)'")
            }.joined(separator: ".\n"))
            """
        }
    }
}

// MARK: - InspectorAnalysisHistoryRecord Filters

extension Array where Element == InspectorAnalysisHistoryRecord {
    
    var unresolvableDependencyDetection: [InspectorAnalysisHistoryRecord] {
        return filter {
            switch $0 {
            case .dependencyNotFound,
                 .typeMismatch,
                 .implicitDependency,
                 .implicitType:
                return true
            case .triedToResolveDependencyInType,
                 .triedToResolveDependencyInRootType,
                 .triedToBuildType:
                return false
            }
        }
    }
    
    var cyclicDependencyDetection: [InspectorAnalysisHistoryRecord] {
        return buildSteps + resolutionSteps
    }
    
    var buildSteps: [InspectorAnalysisHistoryRecord] {
        return filter {
            switch $0 {
            case .triedToBuildType:
                return true
            case .dependencyNotFound,
                 .triedToResolveDependencyInType,
                 .triedToResolveDependencyInRootType,
                 .typeMismatch,
                 .implicitDependency,
                 .implicitType:
                return false
            }
        }
    }
    
    var resolutionSteps: [InspectorAnalysisHistoryRecord] {
        return filter {
            switch $0 {
            case .triedToResolveDependencyInType,
                 .triedToResolveDependencyInRootType,
                 .typeMismatch,
                 .implicitDependency,
                 .implicitType:
                return true
            case .dependencyNotFound,
                 .triedToBuildType:
                return false
            }
        }
    }
}

// MARK: - Utils

private enum LogLevel: String {
    case warning = "warning"
    case error = "error"
}

private extension Printable {
    
    func xcodeLogString(_ logLevel: LogLevel, _ message: String) -> String {
        switch (fileLocation?.line, fileLocation?.file) {
        case (.some(let line), .some(let file)):
            return "\(file):\(line + 1): \(logLevel.rawValue): \(message)."
        case (nil, .some(let file)):
            return "\(file):1: \(logLevel.rawValue): \(message)."
        case (_, nil):
            return "\(logLevel.rawValue): \(message)."
        }
    }
}

