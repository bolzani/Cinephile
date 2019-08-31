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
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var backdrop: UIImageView!
    @IBOutlet weak var overview: UITextView!
    @IBOutlet weak var tagline: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var genres: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = movie.title
        tagline.text = nil
        overview.text = nil
        TMDB.movie(movie.id).then(fillDetails)
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

}
