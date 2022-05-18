//
//  Currency.swift
//  ConvertIt
//
//  Created by Slik on 02.05.2022.
//

import Foundation

struct Currency: Codable, Equatable {
    var identifier: String = ""
    var symbol: String = ""
    var localizedDescription: String = ""
    
    static func ==(lhrs: Currency, rhrs: Currency) -> Bool {
        return lhrs.identifier == rhrs.identifier
    }
}
