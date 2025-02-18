//
//  MovieListViewController.swift
//  MovieFlix
//
//  Created by Dimitrios Tsoumanis on 12/02/2025.
//

import Combine
import UIKit

final class MovieListViewController: UIViewController {
    @IBOutlet weak private var collectionView: UICollectionView!
    private let searchBar = UISearchBar()
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: MovieListViewModel
    private var isRotating = false
    private let refreshControl = UIRefreshControl()
    private let router: AppRouter
    
    init(viewModel: MovieListViewModel, router: AppRouter) {
        self.router = router
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        let nib = UINib(nibName: "MovieListViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "MovieCell")
        collectionView.register(SkeletonCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
        Task {
            self.collectionView.reloadData()
            await viewModel.loadMovies()
        }
        setupBindings()
        setupSearchBar()
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Search movies..."
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func setupBindings() {
        viewModel.$movies
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
                self?.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: RunLoop.main)
            .compactMap { $0?.localizedDescription }
            .sink { [weak self] error in
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: &cancellables)
    }
    
    @objc private func refreshData() {
        Task {
            await viewModel.loadMovies(isRefreshing: true)
        }
    }
}

extension MovieListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let movie = viewModel.movies[indexPath.item]
            if let backdropPath = movie.backdropPath {
                Task {
                    await ImageLoader.shared.prefetchImage(from: "https://image.tmdb.org/t/p/w500\(backdropPath)")
                }
            }
        }
        
        if let maxItem = indexPaths.map({ $0.item }).max(),
           maxItem > viewModel.movies.count - 10 {
            Task {
                await viewModel.loadMovies()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let movie = viewModel.movies[indexPath.item]
            if let backdropPath = movie.backdropPath {
                Task {
                    await ImageLoader.shared.cancelPrefetch(for: "https://image.tmdb.org/t/p/w500\(backdropPath)")
                }
            }
        }
    }
}

extension MovieListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.isLoading, viewModel.movies.isEmpty {
            return 10
        } else if viewModel.isLoading {
            return viewModel.movies.count + 5
        } else {
            return viewModel.movies.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < viewModel.movies.count {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as? MovieListViewCell else {
                return UICollectionViewCell()
            }
            
            let movie = viewModel.movies[indexPath.item]
            cell.configure(with: movie)
            cell.onFavoriteButtonTapped = { [weak self] in
                self?.viewModel.toggleFavorite(at: indexPath.item)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SkeletonCell", for: indexPath) as! SkeletonCollectionViewCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        router.navigate(to: .movieDetails(movieId: viewModel.movies[indexPath.row].id) { [weak self] in
            self?.viewModel.toggleFavorite(at: indexPath.item)
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.bounds.height
        
        if position > contentHeight - screenHeight - 100 {
            Task {
                self.collectionView.reloadData()
                await viewModel.loadMovies()
            }
        }
    }
}

extension MovieListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchQuery = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.searchQuery = ""
    }
}

extension MovieListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 32, height: 170)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
}
