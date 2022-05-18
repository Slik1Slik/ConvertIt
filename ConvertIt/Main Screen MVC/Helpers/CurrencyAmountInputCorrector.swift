//
//  CurrencyAmountInputCorrector.swift
//  ConvertIt
//
//  Created by Slik on 18.05.2022.
//

import Foundation

class CurrencyAmountInputCorrector {
    
    private var value: String!
    
    func correctedValue(of amount: String) -> String {
        self.value = amount
        if value.count == 1 {
            firstEnteredSymbolCheck()
            return value
        }
        if value.count == 2 {
            firstTwoEnteredSymbolsCheck()
            return value
        }
        if value.count > 0 {
            separatorPositionCheck()
            separatorCountCheck()
            boundZeroCheck()
        }
        return value
    }
    
    private func firstEnteredSymbolCheck() {
        if value.first!.isPunctuation {
            value = "0" + Locale.current.decimalSeparatorCharacter
        }
    }
    
    private func firstTwoEnteredSymbolsCheck() {
        guard (String(value.first!)).intValue == 0, String(value.last!).intValue != nil else {
            return
        }
        value = value.prefix(1) + Locale.current.decimalSeparatorCharacter + value.suffix(1)
    }
    
    private func separatorCountCheck() {
        var counter = 0
        value.forEach { char in
            if char == Locale.current.decimalSeparatorCharacter.first! {
                counter += 1
            }
        }
        if counter > 1 {
            let lastSeparatorIndex = value.lastIndex(of: Locale.current.decimalSeparatorCharacter.last!)
            value.remove(at: lastSeparatorIndex!)
        }
    }
    
    private func separatorPositionCheck() {
        if value.first!.isPunctuation {
            value = "0" + value
        }
    }
    
    private func boundZeroCheck() {
        if value.doubleValue! < 1 && value.contains(Locale.current.decimalSeparatorCharacter) {
            var textPart = value.components(separatedBy: Locale.current.decimalSeparatorCharacter)[0]
            textPart.forEach { char in
                guard textPart.count > 1 else { return }
                if char == "0",
                   let charIndex = textPart.firstIndex(of: char),
                   charIndex == textPart.startIndex,
                   textPart[textPart.index(after: charIndex)] == char
                {
                    textPart.remove(at: charIndex)
                    return
                }
            }
            value = textPart + Locale.current.decimalSeparatorCharacter + value.components(separatedBy: Locale.current.decimalSeparatorCharacter)[1]
        }
    }
}
