//
//  CollectionLayoutType.swift
//  Collections
//
//  Created by Felipe Alves on 28/08/19.
//  Copyright © 2019 Bolzaniapps. All rights reserved.
//

import Foundation
import UIKit

enum CollectionLayoutType {
    
    case cards
    case table
    
    func next() -> CollectionLayoutType {
        switch self {
        case .cards: return .table
        case .table: return .cards
        }
    }
    
    var minimumLineSpacing: CGFloat {
        switch self {
        case .table: return 2
        case .cards: return minimumInteritemSpacing
        }
    }
    
    var minimumInteritemSpacing: CGFloat {
        switch self {
        case .table: return 0
        case .cards: return 16
        }
    }
    
    var sectionInsets: UIEdgeInsets {
        return UIEdgeInsets(top: minimumInteritemSpacing, left: minimumInteritemSpacing, bottom: minimumInteritemSpacing, right: minimumInteritemSpacing)
    }
    
    func itemSize(on view: UIView) -> CGSize {
        
        var screenWidth: CGFloat = view.bounds.width
        var screenHeight: CGFloat = view.bounds.height
        
        if #available(iOS 11.0, *) {
            screenWidth -= (view.safeAreaInsets.left + view.safeAreaInsets.right)
            screenHeight -= (view.safeAreaInsets.top + view.safeAreaInsets.bottom)
        }
        
        let isPortrait = UIDevice.current.orientation.isPortrait
        var width: CGFloat
        var height: CGFloat
        
        
        switch (self, isPortrait) {
        case (.table, _):
            width = screenWidth
            height = 140
        case (.cards, true):
            width = (screenWidth/2) - (1.5 * minimumInteritemSpacing)
            height = width * 1.5
        case (.cards, false):
            height = screenHeight - (2 * minimumLineSpacing)
            width = height * (2/3)
        }
        
        return CGSize(width: width, height: height)
    }
}
