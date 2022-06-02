//
//  ExchangeRatesTimeseriesResultResponseParser.swift
//  ConvertIt
//
//  Created by Slik on 02.06.2022.
//

import Foundation

class ExchangeRatesTimeseriesResultResponseParser: ExchangeRatesTimeseriesResultResponseParserProtocol {
    
    typealias ParsingResult = Result<ParsedExchangeRatesTimeseriesResultResponse, ExchangeRatesDataParserError>
    
    static func parse(_ response: ExchangeRatesTimeseriesResultResponse, completion: (ParsingResult) -> ()) {
        
        var rates: [DailyExchangeRate] = []
        
        for element in response.rates {
            if let date = DateConstants.dateFormatter.date(from: element.key) {
                rates.append(DailyExchangeRate(date: date, rate: element.value.values.first!))
            } else {
                completion(.failure(.incorrectDataFormat))
                break
            }
        }
        guard !rates.isEmpty else {
            completion(.failure(.incorrectDataFormat))
            return
        }
        let currencies = UserDataManager.shared.currencies
        let currencyFrom = currencies.first { $0.identifier == response.base }!
        let currencyTo = currencies.first { $0.identifier == response.rates.values.first!.keys.first! }!
        
        completion(.success(ParsedExchangeRatesTimeseriesResultResponse(currencyFrom: currencyFrom,
                                                                        currencyTo: currencyTo,
                                                                        rates: rates,
                                                                        startDate: response.startDate,
                                                                        endDate: response.endDate)))
    }
}

protocol ExchangeRatesTimeseriesResultResponseParserProtocol {
    
    typealias ParsingResult = Result<ParsedExchangeRatesTimeseriesResultResponse, ExchangeRatesDataParserError>
    
    static func parse(_ response: ExchangeRatesTimeseriesResultResponse, completion: (ParsingResult) -> ())
}
