//
//  ViewController.swift
//  Cinephile
//
//  Created by Felipe Alves on 28/08/19.
//  Copyright © 2019 Bolzaniapps. All rights reserved.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var movies = [Movie]()
    let upcoming = TMDB.upcoming()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        loadMore()
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    func loadMore() {
        upcoming
            .loadNextPage()
            .then(insertMovies)
    }

    func insertMovies(_ newMovies: [Movie]) {
        let indexes = calculateNewIndexPaths(newMovies)
        movies.append(contentsOf: newMovies)
        tableView.beginUpdates()
        tableView.insertRows(at: indexes , with: .automatic)
        tableView.endUpdates()
    }
    
    func calculateNewIndexPaths(_ newMovies: [Movie]) -> [IndexPath] {
        let firstIndex = movies.count
        let lastIndex = firstIndex + newMovies.count
        let indexes = (firstIndex..<lastIndex).map({IndexPath(row: $0, section: 0)})
        return indexes
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as! MovieTableViewCell
        cell.imageView?.sd_cancelCurrentImageLoad()
        let movie = movies[indexPath.row]
        cell.setup(with: movie)
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height * 1.1 {
            if upcoming.hasMoreToLoad() {
                loadMore()
            }
        }
    }
    
}

class MovieTableViewCell: UITableViewCell {
    
    static let identifier = "movieTableViewCell"
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = nil
        poster.sd_cancelCurrentImageLoad()
        poster.image = nil
    }
    
    func setup(with movie: Movie) {
        setupShadowAndCorners()
        title.text = movie.title
        poster.sd_setImage(with: movie.posterUrl(size: .w92))
    }
    
    private func setupShadowAndCorners() {
        guard poster.layer.cornerRadius == 0 else { return }
        poster.layer.cornerRadius = 5
        poster.layer.masksToBounds = true
        poster.backgroundColor = .white
    }
    
}
