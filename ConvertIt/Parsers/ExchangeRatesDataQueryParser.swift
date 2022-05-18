//
//  ExchangeRatesDataQueryParser.swift
//  ConvertIt
//
//  Created by Slik on 18.05.2022.
//

import Foundation

class ExchangeRatesDataQueryParser: ExchangeRatesDataQueryParserProtocol {
    
    typealias ParsingResult = Result<ParsedExchangeRatesDataQuery, ExchangeRatesDataParserError>
    
    static func parse(_ query: ExchangeRatesDataResponseQuery, completion: (ParsingResult) -> ()) {
        
        guard let currencyFrom = UserDataManager.shared.currencies.first(where: { $0.identifier == query.from }),
              let currencyTo = UserDataManager.shared.currencies.first(where: { $0.identifier == query.to }) else
        {
            completion(.failure(ExchangeRatesDataParserError.incorrectDataFormat))
            return
        }
        
        completion(
            .success(
                ParsedExchangeRatesDataQuery(currencyFrom: currencyFrom,
                                             currencyTo: currencyTo,
                                             amount: query.amount)
            ))
    }
}

enum ExchangeRatesDataParserError: Error {
    case incorrectDataFormat
    
    var localizedDescription: String {
        switch self {
        case .incorrectDataFormat:
            return "Преобразование данных оказалось неуспешным."
        }
    }
}

protocol ExchangeRatesDataQueryParserProtocol {
    
    typealias ParsingResult = Result<ParsedExchangeRatesDataQuery, ExchangeRatesDataParserError>
    
    static func parse(_ query: ExchangeRatesDataResponseQuery, completion: (ParsingResult) -> ())
}

class MockExchangeRatesDataQueryParser: ExchangeRatesDataQueryParserProtocol {
    static func parse(_ query: ExchangeRatesDataResponseQuery, completion: (ParsingResult) -> ()) {
        let currencies = [
            Currency(identifier: "USD", symbol: "", localizedDescription: ""),
            Currency(identifier: "EUR", symbol: "", localizedDescription: "")
        ]
        if let currencyFrom = currencies.first(where: { $0.identifier == query.from }),
           let currencyTo = currencies.first(where: { $0.identifier == query.to }) {
            completion(.success(
                ParsedExchangeRatesDataQuery(currencyFrom: currencyFrom,
                                             currencyTo: currencyTo,
                                             amount: query.amount)
            ))
        } else {
            completion(.failure(.incorrectDataFormat))
        }
    }
}
