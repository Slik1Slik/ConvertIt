//
//  CurrencyAmountInputChecker.swift
//  ConvertIt
//
//  Created by Slik on 18.05.2022.
//

import Foundation

class CurrencyAmountInputChecker {
    
    private var value: String!
    
    func isInputValueCorrect(_ value: String) -> Bool {
        
        self.value = value
        
        guard !isInputValueEmpty() else {
            return false
        }
        
        return isInputValueDoubleCoercible() &&
                isInputValueNonZero() &&
                isInputValuePositive() &&
                !isLastSymbolOfInputValueSeparator()
    }
    
    private func isInputValueEmpty() -> Bool {
        return value.isEmpty
    }
    
    private func isInputValueDoubleCoercible() -> Bool {
        return value.doubleValue != nil
    }
    
    private func isInputValueNonZero() -> Bool {
        return value.doubleValue! != 0
    }
    
    private func isInputValuePositive() -> Bool {
        return value.doubleValue! > 0
    }
    
    private func isLastSymbolOfInputValueSeparator() -> Bool {
        return value.last!.isPunctuation
    }
}
