//
//  MoviesListViewController.swift
//  Cinephile
//
//  Created by Felipe Alves on 28/08/19.
//  Copyright © 2019 Bolzaniapps. All rights reserved.
//

import UIKit


class MoviesListViewController: UICollectionViewController {

    var movies: [Movie] = []
    var request: PagedRequest = TMDB.upcoming()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = MoviePostersLayout()
        layout.scrollDirection = UIDevice.current.orientation.isLandscape ? .horizontal : .vertical
        collectionView.delaysContentTouches = false
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.register(UINib.init(nibName: "MoviePosterCell", bundle: nil), forCellWithReuseIdentifier: MoviePosterCell.identifier)
        loadMore()
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

// MARK: - UICollectionViewDataSource

extension MoviesListViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movie = movies[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviePosterCell.identifier, for: indexPath) as! MoviePosterCell
        cell.setup(with: movie)
        return cell
    }
    
}

// MARK: - Paging Logic

extension MoviesListViewController {
    
    func loadMore() {
        request
            .loadNextPage()
            .then(insertMovies)
    }
    
    func insertMovies(_ newMovies: [Movie]) {
        let indexes = calculateNewIndexPaths(newMovies)
        movies.append(contentsOf: newMovies)
        collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: indexes)
        })
    }
    
    func calculateNewIndexPaths(_ newMovies: [Movie]) -> [IndexPath] {
        let firstIndex = movies.count
        let lastIndex = firstIndex + newMovies.count
        let indexes = (firstIndex..<lastIndex).map({IndexPath(row: $0, section: 0)})
        return indexes
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height * 1.1 {
            if request.hasMoreToLoad() {
                loadMore()
            }
        }
    }
    
}
