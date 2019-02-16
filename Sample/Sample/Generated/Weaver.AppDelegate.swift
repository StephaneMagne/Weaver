/// This file is generated by Weaver 0.12.0
/// DO NOT EDIT!
import API
import UIKit
// MARK: - AppDelegate
protocol AppDelegateDependencyResolver {
    var logger: Logger { get }
    var urlSession: URLSession { get }
    var movieAPI: APIProtocol { get }
    var imageManager: ImageManaging { get }
    var movieManager: MovieManaging { get }
    var homeViewController: UIViewController { get }
    var reviewManager: ReviewManaging { get }
}
final class AppDelegateDependencyContainer: AppDelegateDependencyResolver {
    private var _logger: Logger?
    var logger: Logger {
        if let value = _logger { return value }
        let value = Logger()
        _logger = value
        return value
    }
    private var _urlSession: URLSession?
    var urlSession: URLSession {
        if let value = _urlSession { return value }
        let value = { _ in URLSession.shared }(self)
        _urlSession = value
        return value
    }
    private var _movieAPI: APIProtocol?
    var movieAPI: APIProtocol {
        if let value = _movieAPI { return value }
        let value = AppDelegate.makeMovieAPI(self)
        _movieAPI = value
        return value
    }
    private var _imageManager: ImageManaging?
    var imageManager: ImageManaging {
        if let value = _imageManager { return value }
        let value = ImageManager()
        _imageManager = value
        return value
    }
    private var _movieManager: MovieManaging?
    var movieManager: MovieManaging {
        if let value = _movieManager { return value }
        let value = AppDelegate.makeMovieManager(self)
        _movieManager = value
        return value
    }
    private var _homeViewController: UIViewController?
    var homeViewController: UIViewController {
        if let value = _homeViewController { return value }
        let dependencies = HomeViewControllerDependencyContainer(injecting: self)
        let value = HomeViewController(injecting: dependencies)
        _homeViewController = value
        return value
    }
    private var _reviewManager: ReviewManaging?
    var reviewManager: ReviewManaging {
        if let value = _reviewManager { return value }
        let dependencies = ReviewManagerDependencyContainer(injecting: self)
        let value = ReviewManager(injecting: dependencies)
        _reviewManager = value
        return value
    }
    init() {
        _ = logger
        _ = urlSession
        _ = movieAPI
        _ = imageManager
        _ = movieManager
        _ = homeViewController
        _ = reviewManager
    }
}
extension AppDelegateDependencyContainer: HomeViewControllerInputDependencyResolver {}
extension AppDelegateDependencyContainer: ReviewManagerInputDependencyResolver {}