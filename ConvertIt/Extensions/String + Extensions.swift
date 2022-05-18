//
//  String + Extensions.swift
//  ConvertIt
//
//  Created by Slik on 02.05.2022.
//

import Foundation

extension String {
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

extension String {
    
     var doubleValue: Double? {
         return NumberFormatter().number(from: self)?.doubleValue
     }

     var intValue: Int? {
         return NumberFormatter().number(from: self)?.intValue
     }
}
