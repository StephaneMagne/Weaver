import API
import Foundation
import UIKit

// swiftlint:disable all
/// This file is generated by Weaver 1.0.9
/// DO NOT EDIT!

@objc final class MainDependencyContainer: NSObject {

    private let provider: Provider

    fileprivate init(provider: Provider = Provider()) {
        self.provider = provider
        super.init()
    }

    private static var _dynamicResolvers = [Any]()
    private static var _dynamicResolversLock = NSRecursiveLock()

    fileprivate static func _popDynamicResolver<Resolver>(_ resolverType: Resolver.Type) -> Resolver {
        guard let dynamicResolver = _dynamicResolvers.removeFirst() as? Resolver else {
            MainDependencyContainer.fatalError()
        }
        return dynamicResolver
    }

    static func _pushDynamicResolver<Resolver>(_ resolver: Resolver) {
        _dynamicResolvers.append(resolver)
    }

    enum Scope {
        case transient
        case container
        case weak
        case lazy
    }

    enum Platform {
        case OSX
        case macOS
        case iOS
        case watchOS
        case tvOS
    }

    enum DependencyKind {
        case registration
        case reference
        case parameter
    }

    private var homeViewControllerBuilder: Provider.Builder<UIViewController> {
        return provider.getBuilder("homeViewController", UIViewController.self)
    }

    private var imageManagerBuilder: Provider.Builder<ImageManaging> {
        return provider.getBuilder("imageManager", ImageManaging.self)
    }

    private var loggerBuilder: Provider.Builder<Logger> {
        return provider.getBuilder("logger", Logger.self)
    }

    private var movieAPIBuilder: Provider.Builder<APIProtocol> {
        return provider.getBuilder("movieAPI", APIProtocol.self)
    }

    private var movieControllerBuilder: Provider.Builder<UIViewController> {
        return provider.getBuilder("movieController", UIViewController.self)
    }

    private var movieIDBuilder: Provider.Builder<UInt> {
        return provider.getBuilder("movieID", UInt.self)
    }

    private var movieManagerBuilder: Provider.Builder<MovieManaging> {
        return provider.getBuilder("movieManager", MovieManaging.self)
    }

    private var movieTitleBuilder: Provider.Builder<String> {
        return provider.getBuilder("movieTitle", String.self)
    }

    private var reviewControllerBuilder: Provider.Builder<WSReviewViewController> {
        return provider.getBuilder("reviewController", WSReviewViewController.self)
    }

    private var reviewManagerBuilder: Provider.Builder<ReviewManaging> {
        return provider.getBuilder("reviewManager", ReviewManaging.self)
    }

    private var urlSessionBuilder: Provider.Builder<URLSession> {
        return provider.getBuilder("urlSession", URLSession.self)
    }

    var homeViewController: UIViewController {
        return homeViewControllerBuilder(nil)
    }

    var imageManager: ImageManaging {
        return imageManagerBuilder(nil)
    }

    var logger: Logger {
        return loggerBuilder(nil)
    }

    var movieAPI: APIProtocol {
        return movieAPIBuilder(nil)
    }

    func movieController(movieID: UInt,
                         movieTitle: String) -> UIViewController {
        return movieControllerBuilder { (provider) in
            provider.setBuilder("movieID", Provider.valueBuilder(movieID))
            provider.setBuilder("movieTitle", Provider.valueBuilder(movieTitle))
        }
    }

    var movieID: UInt {
        return movieIDBuilder(nil)
    }

    var movieManager: MovieManaging {
        return movieManagerBuilder(nil)
    }

    var movieTitle: String {
        return movieTitleBuilder(nil)
    }

    var reviewController: WSReviewViewController {
        return reviewControllerBuilder(nil)
    }

    var reviewManager: ReviewManaging {
        return reviewManagerBuilder(nil)
    }

    var urlSession: URLSession {
        return urlSessionBuilder(nil)
    }

    fileprivate func appDelegateDependencyResolver() -> AppDelegateDependencyResolver {
        let _self = MainDependencyContainer(provider: provider.copy())
        let _inputProvider = _self.provider.copy()
        var _builders = Dictionary<String, Any>()
        _builders["logger"] = Provider.lazyBuilder( { (_: Optional<Provider.ParametersCopier>) -> Logger in return Logger() })
        _builders["urlSession"] = Provider.lazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> URLSession in
                let _inputContainer = MainDependencyContainer(provider: _inputProvider)
                return AppDelegate.makeURLSession(_inputContainer as URLSessionInputDependencyResolver)
            }
        )
        _builders["movieAPI"] = Provider.lazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> APIProtocol in
                let _inputContainer = MainDependencyContainer(provider: _inputProvider)
                return AppDelegate.makeMovieAPI(_inputContainer as MovieAPIInputDependencyResolver)
            }
        )
        _builders["imageManager"] = Provider.lazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> ImageManaging in return ImageManager() }
        )
        _builders["movieManager"] = Provider.lazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> MovieManaging in
                let _inputContainer = MainDependencyContainer(provider: _inputProvider)
                return AppDelegate.makeMovieManager(_inputContainer as MovieManagingInputDependencyResolver)
            }
        )
        _builders["homeViewController"] = Provider.lazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> UIViewController in
                defer { MainDependencyContainer._dynamicResolversLock.unlock() }
                MainDependencyContainer._dynamicResolversLock.lock()
                let _inputContainer = MainDependencyContainer(provider: _inputProvider)
                let __self = _inputContainer.homeViewControllerDependencyResolver()
                return HomeViewController(injecting: __self)
            }
        )
        _builders["reviewManager"] = Provider.lazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> ReviewManaging in
                defer { MainDependencyContainer._dynamicResolversLock.unlock() }
                MainDependencyContainer._dynamicResolversLock.lock()
                let _inputContainer = MainDependencyContainer(provider: _inputProvider)
                let __self = _inputContainer.reviewManagerDependencyResolver()
                return ReviewManager(injecting: __self)
            }
        )
        _self.provider.addBuilders(_builders)
        _inputProvider.addBuilders(_builders)
        _ = _self.logger
        _ = _self.urlSession
        _ = _self.movieAPI
        _ = _self.imageManager
        _ = _self.movieManager
        _ = _self.homeViewController
        _ = _self.reviewManager
        MainDependencyContainer._pushDynamicResolver({ _self.logger })
        MainDependencyContainer._pushDynamicResolver({ _self.urlSession })
        MainDependencyContainer._pushDynamicResolver({ _self.movieAPI })
        MainDependencyContainer._pushDynamicResolver({ _self.imageManager })
        MainDependencyContainer._pushDynamicResolver({ _self.movieManager })
        MainDependencyContainer._pushDynamicResolver({ _self.homeViewController })
        return _self
    }

    static func appDelegateDependencyResolver() -> AppDelegateDependencyResolver {
        let _self = MainDependencyContainer().appDelegateDependencyResolver()
        return _self
    }

    private func personManagerDependencyResolver() -> PersonManagerDependencyResolver {
        let _self = MainDependencyContainer()
        var _builders = Dictionary<String, Any>()
        _builders["logger"] = Provider.lazyBuilder( { (_: Optional<Provider.ParametersCopier>) -> Logger in return Logger() })
        _builders["movieAPI"] = _self.movieAPIBuilder
        _self.provider.addBuilders(_builders)
        _ = _self.logger
        MainDependencyContainer._pushDynamicResolver({ _self.logger })
        MainDependencyContainer._pushDynamicResolver({ _self.movieAPI })
        return _self
    }

    private func reviewManagerDependencyResolver() -> ReviewManagerDependencyResolver {
        let _self = MainDependencyContainer()
        var _builders = Dictionary<String, Any>()
        _builders["logger"] = Provider.lazyBuilder( { (_: Optional<Provider.ParametersCopier>) -> Logger in return Logger() })
        _builders["movieAPI"] = movieAPIBuilder
        _self.provider.addBuilders(_builders)
        _ = _self.logger
        MainDependencyContainer._pushDynamicResolver({ _self.logger })
        MainDependencyContainer._pushDynamicResolver({ _self.movieAPI })
        return _self
    }

    private func homeViewControllerDependencyResolver() -> HomeViewControllerDependencyResolver {
        let _self = MainDependencyContainer(provider: provider.copy())
        let _inputProvider = _self.provider.copy()
        var _builders = Dictionary<String, Any>()
        _builders["logger"] = Provider.lazyBuilder( { (_: Optional<Provider.ParametersCopier>) -> Logger in return Logger() })
        _builders["movieController"] = Provider.weakLazyBuilder(
             { (copyParameters: Optional<Provider.ParametersCopier>) -> UIViewController in
                defer { MainDependencyContainer._dynamicResolversLock.unlock() }
                MainDependencyContainer._dynamicResolversLock.lock()
                let _inputContainer = MainDependencyContainer(provider: _inputProvider)
                let __self = _inputContainer.movieViewControllerDependencyResolver()
                copyParameters?((__self as! MainDependencyContainer).provider)
                return MovieViewController(injecting: __self)
            }
        )
        _builders["imageManager"] = imageManagerBuilder
        _builders["movieManager"] = movieManagerBuilder
        _builders["reviewManager"] = reviewManagerBuilder
        _self.provider.addBuilders(_builders)
        _inputProvider.addBuilders(_builders)
        _ = _self.logger
        MainDependencyContainer._pushDynamicResolver({ _self.logger })
        MainDependencyContainer._pushDynamicResolver({ _self.movieManager })
        MainDependencyContainer._pushDynamicResolver(_self.movieController)
        return _self
    }

    private func movieViewControllerDependencyResolver() -> MovieViewControllerDependencyResolver {
        let _self = MainDependencyContainer(provider: provider.copy())
        let _inputProvider = _self.provider
        var _builders = Dictionary<String, Any>()
        _builders["logger"] = Provider.lazyBuilder( { (_: Optional<Provider.ParametersCopier>) -> Logger in return Logger() })
        _builders["reviewController"] = Provider.weakLazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> WSReviewViewController in
                let _inputContainer = MainDependencyContainer(provider: _inputProvider.copy())
                return WSReviewViewController.make(_inputContainer as WSReviewViewControllerInputDependencyResolver)
            }
        )
        _builders["imageManager"] = imageManagerBuilder
        _builders["movieManager"] = movieManagerBuilder
        _builders["reviewManager"] = reviewManagerBuilder
        _self.provider.addBuilders(_builders)
        _ = _self.logger
        MainDependencyContainer._pushDynamicResolver({ _self.logger })
        MainDependencyContainer._pushDynamicResolver({ _self.movieID })
        MainDependencyContainer._pushDynamicResolver({ _self.movieTitle })
        MainDependencyContainer._pushDynamicResolver({ _self.movieManager })
        MainDependencyContainer._pushDynamicResolver({ _self.imageManager })
        MainDependencyContainer._pushDynamicResolver({ _self.reviewManager })
        MainDependencyContainer._pushDynamicResolver({ _self.reviewController })
        return _self
    }
}

@objc protocol HomeViewControllerResolver: AnyObject {
    var homeViewController: UIViewController { get }
}

protocol ImageManagerResolver: AnyObject {
    var imageManager: ImageManaging { get }
}

protocol LoggerResolver: AnyObject {
    var logger: Logger { get }
}

protocol MovieAPIResolver: AnyObject {
    var movieAPI: APIProtocol { get }
}

protocol MovieControllerResolver: AnyObject {
    func movieController(movieID: UInt, movieTitle: String) -> UIViewController
}

protocol MovieIDResolver: AnyObject {
    var movieID: UInt { get }
}

protocol MovieManagerResolver: AnyObject {
    var movieManager: MovieManaging { get }
}

protocol MovieTitleResolver: AnyObject {
    var movieTitle: String { get }
}

protocol ReviewControllerResolver: AnyObject {
    var reviewController: WSReviewViewController { get }
}

@objc protocol ReviewManagerResolver: AnyObject {
    var reviewManager: ReviewManaging { get }
}

protocol UrlSessionResolver: AnyObject {
    var urlSession: URLSession { get }
}

extension MainDependencyContainer: HomeViewControllerResolver, ImageManagerResolver, LoggerResolver, MovieAPIResolver, MovieControllerResolver, MovieIDResolver, MovieManagerResolver, MovieTitleResolver, ReviewControllerResolver, ReviewManagerResolver, UrlSessionResolver {
}

extension MainDependencyContainer {
}

typealias AppDelegateDependencyResolver = LoggerResolver & UrlSessionResolver & MovieAPIResolver & ImageManagerResolver & MovieManagerResolver & HomeViewControllerResolver & ReviewManagerResolver

typealias PersonManagerDependencyResolver = LoggerResolver & MovieAPIResolver

typealias ReviewManagerDependencyResolver = LoggerResolver & MovieAPIResolver

typealias HomeViewControllerDependencyResolver = LoggerResolver & MovieManagerResolver & MovieControllerResolver

typealias MovieViewControllerDependencyResolver = LoggerResolver & MovieIDResolver & MovieTitleResolver & MovieManagerResolver & ImageManagerResolver & ReviewManagerResolver & ReviewControllerResolver

typealias MovieAPIInputDependencyResolver = HomeViewControllerResolver & ImageManagerResolver & LoggerResolver & MovieAPIResolver & MovieManagerResolver & ReviewManagerResolver & UrlSessionResolver

typealias MovieManagingInputDependencyResolver = HomeViewControllerResolver & ImageManagerResolver & LoggerResolver & MovieAPIResolver & MovieManagerResolver & ReviewManagerResolver & UrlSessionResolver

typealias URLSessionInputDependencyResolver = HomeViewControllerResolver & ImageManagerResolver & LoggerResolver & MovieAPIResolver & MovieManagerResolver & ReviewManagerResolver & UrlSessionResolver

typealias WSReviewViewControllerInputDependencyResolver = ImageManagerResolver & LoggerResolver & MovieIDResolver & MovieManagerResolver & MovieTitleResolver & ReviewControllerResolver & ReviewManagerResolver

@propertyWrapper
struct Weaver<ConcreteType, AbstractType> {

    typealias Resolver = () -> AbstractType
    let resolver = MainDependencyContainer._popDynamicResolver(Resolver.self)

    init(_ kind: MainDependencyContainer.DependencyKind,
         type: ConcreteType.Type,
         scope: MainDependencyContainer.Scope = .container,
         setter: Bool = false,
         escaping: Bool = false,
         builder: Optional<Any> = nil,
         objc: Bool = false,
         platforms: Array<MainDependencyContainer.Platform> = []) {
        // no-op
    }

    var wrappedValue: AbstractType {
        return resolver()
    }
}

extension Weaver where ConcreteType == Void {
    init(_ kind: MainDependencyContainer.DependencyKind,
         scope: MainDependencyContainer.Scope = .container,
         setter: Bool = false,
         escaping: Bool = false,
         builder: Optional<Any> = nil,
         objc: Bool = false,
         platforms: Array<MainDependencyContainer.Platform> = []) {
        // no-op
    }
}

@propertyWrapper
struct WeaverP2<ConcreteType, AbstractType, P1, P2> {

    typealias Resolver = (P1, P2) -> AbstractType
    let resolver = MainDependencyContainer._popDynamicResolver(Resolver.self)

    init(_ kind: MainDependencyContainer.DependencyKind,
         type: ConcreteType.Type,
         scope: MainDependencyContainer.Scope = .container,
         setter: Bool = false,
         escaping: Bool = false,
         builder: Optional<Any> = nil,
         objc: Bool = false,
         platforms: Array<MainDependencyContainer.Platform> = []) {
        // no-op
    }

    var wrappedValue: Resolver {
        return resolver
    }
}

extension WeaverP2 where ConcreteType == Void {
    init(_ kind: MainDependencyContainer.DependencyKind,
         scope: MainDependencyContainer.Scope = .container,
         setter: Bool = false,
         escaping: Bool = false,
         builder: Optional<Any> = nil,
         objc: Bool = false,
         platforms: Array<MainDependencyContainer.Platform> = []) {
        // no-op
    }
}

// MARK: - Fatal Error

extension MainDependencyContainer {

    static var onFatalError: (String, StaticString, UInt) -> Never = { message, file, line in
        Swift.fatalError(message, file: file, line: line)
    }

    fileprivate static func fatalError(file: StaticString = #file, line: UInt = #line) -> Never {
        onFatalError("Invalid memory graph. This is never suppose to happen. Please file a ticket at https://github.com/scribd/Weaver", file, line)
    }
}

// MARK: - Provider

private final class Provider {

    typealias ParametersCopier = (Provider) -> Void
    typealias Builder<T> = (ParametersCopier?) -> T

    private(set) var builders: Dictionary<String, Any>

    init(builders: Dictionary<String, Any> = [:]) {
        self.builders = builders
    }
}

private extension Provider {

    func addBuilders(_ builders: Dictionary<String, Any>) {
        builders.forEach { key, value in
            self.builders[key] = value
        }
    }

    func setBuilder<T>(_ name: String, _ builder: @escaping Builder<T>) {
        builders[name] = builder
    }

    func getBuilder<T>(_ name: String, _ type: T.Type) -> Builder<T> {
        guard let builder = builders[name] as? Builder<T> else {
            return Provider.fatalBuilder()
        }
        return builder
    }

    func copy() -> Provider {
        return Provider(builders: builders)
    }
}

private extension Provider {

    static func valueBuilder<T>(_ value: T) -> Builder<T> {
        return { _ in
            return value
        }
    }

    static func weakOptionalValueBuilder<T>(_ value: Optional<T>) -> Builder<Optional<T>> where T: AnyObject {
        return { [weak value] _ in
            return value
        }
    }

    static func lazyBuilder<T>(_ builder: @escaping Builder<T>) -> Builder<T> {
        var _value: T?
        return { copyParameters in
            if let value = _value {
                return value
            }
            let value = builder(copyParameters)
            _value = value
            return value
        }
    }

    static func weakLazyBuilder<T>(_ builder: @escaping Builder<T>) -> Builder<T> where T: AnyObject {
        weak var _value: T?
        return { copyParameters in
            if let value = _value {
                return value
            }
            let value = builder(copyParameters)
            _value = value
            return value
        }
    }

    static func fatalBuilder<T>() -> Builder<T> {
        return { _ in
            MainDependencyContainer.fatalError()
        }
    }
}
