//
//  MovieDetailsViewController.swift
//  Cinephile
//
//  Created by Felipe Alves on 30/08/19.
//  Copyright © 2019 Bolzaniapps. All rights reserved.
//

import UIKit
import SDWebImage

class MovieDetailsViewController: UIViewController {

    var movie: Movie!
    var recommendations = [Movie]()
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var backdrop: UIImageView!
    @IBOutlet weak var overview: UITextView!
    @IBOutlet weak var tagline: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var genres: UILabel!
    @IBOutlet weak var similarTitle: UILabel!
    @IBOutlet weak var recommendationsCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = movie.title
        tagline.text = nil
        overview.text = nil
        score.text = nil
        similarTitle.isHidden = true
        TMDB.movie(movie.id).then(fillDetails)
        TMDB.similarMovies(movie.id).then(showRecommendations)
        poster.sd_setImage(with: movie.posterUrl(size: .w154))
        backdrop.sd_setImage(with: movie.backdropUrl(size: .w780))
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        releaseDate.text = formatter.string(from: movie.releaseDate)
        score.text = "\(movie.voteAverage)"
    }
    
    func fillDetails(_ movie: Movie) {
        tagline.text = movie.tagline
        genres.text = movie.genres.map({$0.name}).joined(separator: ", ")
        overview.text = movie.overview
    }
    
    func showRecommendations(_ movies: [Movie]) {
        recommendations = movies
        similarTitle.isHidden = movies.count == 0
        recommendationsCollection.reloadData()
    }

}

extension MovieDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendations.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecomendationCell", for: indexPath)
        let rec = recommendations[indexPath.row]
        let imageView = cell.viewWithTag(100) as! UIImageView
        imageView.sd_setImage(with: rec.posterUrl(size: .w154))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.layer.cornerRadius = 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = recommendations[indexPath.row]
        let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MovieDetailsViewController") as! MovieDetailsViewController
        details.movie = movie
        navigationController?.pushViewController(details, animated: true)
    }
    
}
