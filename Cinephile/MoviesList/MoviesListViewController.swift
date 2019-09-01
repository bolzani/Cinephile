//
//  MoviesListViewController.swift
//  Cinephile
//
//  Created by Felipe Alves on 28/08/19.
//  Copyright © 2019 Bolzaniapps. All rights reserved.
//

import UIKit

class MoviesListViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: Properties
    
    var upcomingMovies: [Movie] = []
    var searchResultMovies: [Movie] = []
    var isSearching: Bool { return searchController.isActive }
    
    var upcomingRequest: PagedRequest = TMDB.upcoming()
    var searchRequest: PagedRequest?
    
    var searchController: UISearchController!
    var currentSearch: String?
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSearch()
        loadMore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }
        
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.scrollDirection = UIDevice.current.orientation.isLandscape ? .horizontal : .vertical
        coordinator.animate( alongsideTransition: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
    
}

// MARK: - View setup

extension MoviesListViewController {
    
    func setupCollectionView() {
        let layout = MoviePostersLayout()
        layout.scrollDirection = UIDevice.current.orientation.isLandscape ? .horizontal : .vertical
        collectionView.delaysContentTouches = false
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(UINib.init(nibName: "MoviePosterCell", bundle: nil), forCellWithReuseIdentifier: MoviePosterCell.identifier)
    }
    
    func setupSearch() {
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .white
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }
    
}

// MARK: - UICollectionViewDataSource

extension MoviesListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return searchResultMovies.count
        } else {
            return upcomingMovies.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movie = isSearching ? searchResultMovies[indexPath.row] : upcomingMovies[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviePosterCell.identifier, for: indexPath) as! MoviePosterCell
        cell.setup(with: movie)
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension MoviesListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = isSearching ? searchResultMovies[indexPath.row] : upcomingMovies[indexPath.row]
        let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MovieDetailsViewController") as! MovieDetailsViewController
        details.movie = movie
        navigationController?.pushViewController(details, animated: true)
    }
    
}

// MARK: - Paging Logic

extension MoviesListViewController: UIScrollViewDelegate {
    
    func loadMore() {
        if isSearching {
            searchRequest?
                .loadNextPage()
                .then(insertMovies)
        } else {
            upcomingRequest
                .loadNextPage()
                .then(insertMovies)
        }
    }
    
    func insertMovies(_ newMovies: [Movie]) {
        let indexes = calculateNewIndexPaths(newMovies)
        if isSearching {
            searchResultMovies.append(contentsOf: newMovies)
        } else {
            upcomingMovies.append(contentsOf: newMovies)
        }
        spinner.stopAnimating()
        collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: indexes)
        })
    }
    
    func calculateNewIndexPaths(_ newMovies: [Movie]) -> [IndexPath] {
        let firstIndex = isSearching ? searchResultMovies.count : upcomingMovies.count
        let lastIndex = firstIndex + newMovies.count
        let indexes = (firstIndex..<lastIndex).map({IndexPath(row: $0, section: 0)})
        return indexes
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height * 1.1 {
            if isSearching {
                if searchRequest?.hasMoreToLoad() ?? false {
                    loadMore()
                }
            } else {
                if upcomingRequest.hasMoreToLoad() {
                    loadMore()
                }
            }
        }
    }
    
}

// MARK: - UISearchResultsUpdating

extension MoviesListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let newSearch = searchController.searchBar.text!
        if let oldSearch = currentSearch, oldSearch == newSearch, !newSearch.isEmpty {
            return
        }
        currentSearch = newSearch
        searchRequest?.reset()
        searchResultMovies.removeAll()
        collectionView.reloadSections([0])
        if (!isSearching) {
            collectionView.setContentOffset(CGPoint(x: 0, y: -100), animated: false)
        } else {
            searchRequest = TMDB.search(newSearch)
            loadMore()
        }
    }
    
}
