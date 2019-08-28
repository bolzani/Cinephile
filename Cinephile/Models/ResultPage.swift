//
//  ResultPage.swift
//  Cinephile
//
//  Created by Felipe Alves on 28/08/19.
//  Copyright © 2019 Bolzaniapps. All rights reserved.
//

import Foundation
import Arrow

struct ResultPage {
    
    var results: [Movie] = []
    var page: Int = 1
    var totalResults: Int = 0
    var dateMax: Date?
    var dateMin: Date?
    var totalPages: Int = 0
    
}

extension ResultPage: ArrowParsable {
    
    mutating func deserialize(_ json: JSON) {
        
        results <-- json["results"]
        page <-- json["page"]
        totalResults <-- json["total_results"]
        dateMax <-- json["dates.maximum"]?.dateFormat("YYYY-MM-DD")
        dateMin <-- json["dates.minimum"]?.dateFormat("YYYY-MM-DD")
        totalPages <-- json["total_pages"]
        
    }
    
}
