//
//  MoviePosterCell.swift
//  Cinephile
//
//  Created by Felipe Alves on 30/08/19.
//  Copyright © 2019 Bolzaniapps. All rights reserved.
//

import UIKit
import SDWebImage

class MoviePosterCell: UICollectionViewCell {

    static let identifier = "MoviePosterCell"
    override var bounds: CGRect { didSet { addShadowAndRoundedCorners() } }
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var genres: UILabel!
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        poster.sd_cancelCurrentImageLoad()
        poster.image = nil
        title.text = nil
        releaseDate.text = nil
        genres.text = nil
    }
    
    func setup(with movie: Movie) {
        poster.sd_setImage(with: movie.posterUrl(size: .w342))
        title.text = movie.title
        releaseDate.text = formatter.string(from: movie.releaseDate)
        TMDB.genres().then({ genres in
            let genresString = genres.filter{movie.genreIds.contains($0.id)}.map({$0.name}).joined(separator: ", ")
            self.genres.text = genresString
        })
    }

}

// MARK: - Customize appearance

private extension MoviePosterCell {
    
    func addShadowAndRoundedCorners() {
        
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 2)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath
        
        // Rounded corners
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        
    }
    
}

// MARK: - Animate tap

extension MoviePosterCell {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        transformAnimated(CGAffineTransform(scaleX: 0.95, y: 0.95))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        transformAnimated(.identity)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        transformAnimated(.identity)
    }
    
    private func transformAnimated(_ transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: transform == .identity ? 0.3 : 1,
                       initialSpringVelocity: 8,
                       options: [.allowUserInteraction], animations: {
                        self.transform = transform
                        if transform == .identity {
                            self.layer.shadowRadius = 2.0
                        } else {
                            self.layer.shadowRadius = 0.0
                        }
        }, completion: nil)
    }
    
}
