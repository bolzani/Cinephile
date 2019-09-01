//
//  MovieGenre.swift
//  Cinephile
//
//  Created by Felipe Alves on 29/08/19.
//  Copyright © 2019 Bolzaniapps. All rights reserved.
//

import Foundation
import Arrow

struct MovieGenre {
    var id: Int = 0
    var name: String = ""
}

extension MovieGenre: ArrowParsable {
    
    mutating func deserialize(_ json: JSON) {
        
        id <-- json["id"]
        name <-- json["name"]
        
    }
    
}
