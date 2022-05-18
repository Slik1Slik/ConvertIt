//
//  Locale + Extensions.swift
//  ConvertIt
//
//  Created by Slik on 17.05.2022.
//

import Foundation

extension Locale {
    var decimalSeparatorCharacter: String {
        return self.decimalSeparator ?? ","
    }
}
