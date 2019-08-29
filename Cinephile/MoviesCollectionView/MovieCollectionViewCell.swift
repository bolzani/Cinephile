//
//  MovieCollectionViewCell.swift
//  Cinephile
//
//  Created by Felipe Alves on 28/08/19.
//  Copyright © 2019 Bolzaniapps. All rights reserved.
//

import UIKit
import SDWebImage

protocol LayoutProvider: class {
    var layout: CollectionLayoutType { get }
}

class MovieCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MovieCollectionViewCell"
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var genresLabel: UILabel!
    private weak var layoutProvider: LayoutProvider?
    private var isPortrait: Bool { return UIDevice.current.orientation.isPortrait }
    
    override var bounds: CGRect {  didSet { setupShadowAndCorners() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
        genresLabel.text = nil
    }
    
    func setup(with item: Movie, delegate: LayoutProvider) {
        layoutProvider = delegate
        var size: Movie.PosterSize!
        switch (delegate.layout, isPortrait) {
        case (.table, _):
            size = .w92
        case (.cards, true):
            size = .w185
        case (.cards, false):
            size = .w342
        }
        imageView.sd_setImage(with: item.posterUrl(size: size))

        TMDB.genres().then({ genres in
            let genresString = genres.filter{item.genreIds.contains($0.id)}.map({$0.name}).joined(separator: ", ")
            self.genresLabel.text = genresString
        })
    }
    
    //MARK:- Events
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
}

private extension MovieCollectionViewCell {
    
    func transformAnimated(_ transform: CGAffineTransform, completion: ((Bool)->Void)? = nil) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: transform == .identity ? 0.3 : 1,
                       initialSpringVelocity: 8,
                       options: [.allowUserInteraction], animations: {
                        self.transform = transform
                        if (self.layoutProvider?.layout ?? .cards != .table) {
                            if transform == .identity {
                                self.addShadowToViewLayer()
                            } else {
                                self.removeShadowFromViewLayer()
                            }
                        }
        }, completion: completion)
    }
    
    func setupShadowAndCorners() {
        var layout = CollectionLayoutType.cards
        if let provider = layoutProvider { layout = provider.layout }
        if (layout == .table) {
            removeRoundedCornersFromContentViewLayer()
            removeShadowFromViewLayer()
        } else {
            addRoundedCornersToContentViewLayer()
            addShadowToViewLayer()
        }
    }
    
    func addShadowToViewLayer() {
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath
    }
    
    func removeShadowFromViewLayer() {
        self.layer.shadowColor = nil
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 0
        self.layer.shadowOpacity = 0
        self.layer.masksToBounds = true
        self.layer.shadowPath = nil
    }
    
    func addRoundedCornersToContentViewLayer() {
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = .white
    }
    
    func removeRoundedCornersFromContentViewLayer() {
        self.contentView.layer.cornerRadius = 0
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = .white
    }
    
}
