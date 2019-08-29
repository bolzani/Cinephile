//
//  MoviesCollectionViewController.swift
//  Cinephile
//
//  Created by Felipe Alves on 28/08/19.
//  Copyright © 2019 Bolzaniapps. All rights reserved.
//

import UIKit

private let reuseIdentifier = MovieCollectionViewCell.identifier

class MoviesCollectionViewController: UICollectionViewController {

    var movies: [Movie] = []
    var request: PagedRequest = TMDB.upcoming()
    lazy var listBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "tabbaricon_list"), style: .plain, target: self, action: #selector(changeLayout))
    lazy var collectionBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "tabbaricon_collection"), style: .plain, target: self, action: #selector(changeLayout))
    var layout = CollectionLayoutType.cards
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.rightBarButtonItem = listBarButtonItem
        collectionView.delaysContentTouches = false
        loadMore()        
    }
    
    @objc func changeLayout() {
        layout = layout.next()
        navigationItem.rightBarButtonItem = layout == .table ? collectionBarButtonItem : listBarButtonItem
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    // Changing layout and scroll direction according to orientation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = UIDevice.current.orientation.isLandscape ? .horizontal : .vertical
        }
        coordinator.animate(alongsideTransition: { (context) in
            self.collectionView.performBatchUpdates(nil, completion: nil)
        }, completion: nil)
    }
    
}

// MARK: - LayoutProvider

extension MoviesCollectionViewController: LayoutProvider {}

// MARK: - UICollectionViewDataSource

extension MoviesCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MovieCollectionViewCell
        let movie = movies[indexPath.row]
        cell.setup(with: movie, delegate: self)
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MoviesCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return layout.itemSize(on: view)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return layout.minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return layout.minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return layout.sectionInsets
    }
    
}

// MARK: - Paging Logic

extension MoviesCollectionViewController {
    
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
