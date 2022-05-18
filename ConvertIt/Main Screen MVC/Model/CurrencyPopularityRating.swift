//
//  CurrencyPopularity.swift
//  ConvertIt
//
//  Created by Slik on 10.05.2022.
//

import Foundation

struct CurrencyPopularityRating: Codable {
    var id: String = ""
    var popularity: Int = 0
    
    init(id: String, popularity: Int) {
        self.id = id
        self.popularity = popularity
    }
}
