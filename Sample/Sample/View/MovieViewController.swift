//
//  MovieViewController.swift
//  Sample
//
//  Created by Théophane Rupin on 4/5/18.
//  Copyright © 2018 Scribd. All rights reserved.
//

import Foundation
import UIKit
import API

final class MovieViewController: UIViewController {
    
    struct ViewModel {
        let thumbnail: String
        let overview: String?
    }
    
    @Weaver(.reference)
    private var logger: Logger

    @Weaver(.parameter)
    private var movieID: UInt
    
    @Weaver(.parameter)
    private var movieTitle: String
        
    @Weaver(.reference)
    private var movieManager: MovieManaging

    @Weaver(.reference)
    private var imageManager: ImageManaging

    @Weaver(.reference)
    private var reviewManager: ReviewManaging

    @Weaver(.registration, scope: .weak, builder: WSReviewViewController.make)
    private var reviewController: WSReviewViewController
    
    private var originalBarStyle: UIBarStyle?
    
    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(imageTapGestureRecognizer)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .natural
        return label
    }()
    
    private lazy var imageTapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImage(_:)))
        recognizer.numberOfTapsRequired = 1
        return recognizer
    }()

    required init(injecting _: MovieViewControllerDependencyResolver) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        logger.log(.debug, "\(MovieViewController.self): deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        originalBarStyle = navigationController?.navigationBar.barStyle
        navigationController?.navigationBar.barStyle = .blackTranslucent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        originalBarStyle.flatMap { navigationController?.navigationBar.barStyle = $0 }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logger.log(.info, "Showing movie: \(movieTitle).")
        
        title = movieTitle
        view.backgroundColor = .black
        edgesForExtendedLayout = []

        view.addSubview(thumbnailImageView)
        view.addSubview(overviewLabel)
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 2),
            thumbnailImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            
            overviewLabel.topAnchor.constraint(equalToSystemSpacingBelow: thumbnailImageView.bottomAnchor, multiplier: 2),
            overviewLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: overviewLabel.trailingAnchor, multiplier: 2),
            view.bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: overviewLabel.bottomAnchor, multiplier: 2)
        ])
        
        loadData { viewModel in
            self.imageManager.getImage(with: viewModel.thumbnail) { result in
                switch result {
                case .success(let image):
                    self.thumbnailImageView.image = image
                case .failure(let error):
                    self.logger.log(.error, "\(error)")
                }
            }
            
            self.overviewLabel.text = viewModel.overview
        }
    }
    
    private func loadData(completion: @escaping (ViewModel) -> ()) {
        movieManager.getMovie(id: movieID) { result in
            switch result {
            case .success(let movie):
                completion(ViewModel(movie))
            case .failure(let error):
                self.logger.log(.error, "\(error)")
                completion(ViewModel())
            }
        }
    }
}

// MARK: - GestureRecognizer

private extension MovieViewController {
    
    @objc func didTapImage(_: UITapGestureRecognizer) {
        navigationController?.pushViewController(reviewController, animated: true)
    }
}

private extension MovieViewController.ViewModel {
    
    init() {
        thumbnail = ""
        overview = nil
    }
    
    init(_ movie: Movie) {
        thumbnail = movie.poster_path
        overview = movie.overview
    }
}

// MARK: - Custom builder

extension WSReviewViewController {
    
    static func make(_ dependencies: WSReviewViewControllerInputDependencyResolver) -> WSReviewViewController {
        return WSReviewViewController(dependencies, movieID: dependencies.movieID)
    }
}
