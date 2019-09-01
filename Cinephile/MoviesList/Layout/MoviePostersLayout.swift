//
//  MoviePostersLayout.swift
//  Cinephile
//
//  Created by Felipe Alves on 30/08/19.
//  Copyright © 2019 Bolzaniapps. All rights reserved.
//

import UIKit

class MoviePostersLayout: UICollectionViewFlowLayout {

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        minimumLineSpacing = 8
        minimumInteritemSpacing = 8
        sectionInset = UIEdgeInsets(top: minimumInteritemSpacing, left: minimumInteritemSpacing, bottom: minimumInteritemSpacing, right: minimumInteritemSpacing)
    }
        
    override var itemSize: CGSize {
        get { return calculateItemSize()  }
        set {}
    }
    
    private func calculateItemSize() -> CGSize {
        
        var screenWidth: CGFloat = collectionView!.bounds.width
        var screenHeight: CGFloat =  collectionView!.bounds.height
        
        if #available(iOS 11.0, *) {
            screenWidth -= (collectionView!.safeAreaInsets.left + collectionView!.safeAreaInsets.right)
            screenHeight -= (collectionView!.safeAreaInsets.top + collectionView!.safeAreaInsets.bottom)
        }
        
        let isPortrait = !UIDevice.current.orientation.isLandscape
        var width: CGFloat
        var height: CGFloat
        
        if isPortrait {
            width = (screenWidth - 3 * minimumInteritemSpacing) / 2
            height = width * 1.5 + 86
        } else {
            height = screenHeight - (2 * minimumLineSpacing)
            width = height * (2/3)
        }
        
        return CGSize(width: width, height: height)
    }
    
}
