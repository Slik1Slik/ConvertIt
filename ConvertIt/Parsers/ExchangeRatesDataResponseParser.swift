//
//  ExchangeRatesDataResponseParser.swift
//  ConvertIt
//
//  Created by Slik on 16.05.2022.
//

import Foundation

class ExchangeRatesDataResponseParser: ExchangeRatesDataResponseParserProtocol {
    
    typealias ParsingResult = Result<ParsedExchangeRatesDataResponse, ExchangeRatesDataParserError>
    
    static func parse(_ response: ExchangeRatesDataResponse, completion: (ParsingResult) -> ()) {
        ExchangeRatesDataQueryParser.parse(response.query) { result in
            switch result {
            case .success(let query):
                completion(
                    .success(ParsedExchangeRatesDataResponse(date: response.date,
                                                             timestamp: response.info.timestamp,
                                                             query: query,
                                                             result: response.result,
                                                             rate: response.info.rate,
                                                             isSuccessful: response.success))
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

protocol ExchangeRatesDataResponseParserProtocol {
    
    typealias ParsingResult = Result<ParsedExchangeRatesDataResponse, ExchangeRatesDataParserError>
    
    static func parse(_ response: ExchangeRatesDataResponse, completion: (ParsingResult) -> ())
}
