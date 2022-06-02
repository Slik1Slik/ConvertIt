//
//  ExchangeRatesDataResponse.swift
//  ConvertIt
//
//  Created by Slik on 01.05.2022.
//

import Foundation

struct ExchangeRatesConversionResultResponse: Codable {
    var date: Date = Date()
    var info: ExchangeRatesConversionResultResponseInfo = ExchangeRatesConversionResultResponseInfo()
    var query: ExchangeRatesConversionResultResponseQuery = ExchangeRatesConversionResultResponseQuery()
    var result: Double = 0
    var success: Bool = false
}

struct ExchangeRatesConversionResultResponseInfo: Codable {
    var rate: Double = 0
    var timestamp: Double = 0
}

struct ExchangeRatesConversionResultResponseQuery: Codable {
    var amount: Double = 0
    var from: String = ""
    var to: String = ""
}

struct ParsedExchangeRatesConversionResultResponse: Codable {
    var date: Date = Date()
    var timestamp: Double = 0
    var query: ParsedExchangeRatesConversionResultQuery = ParsedExchangeRatesConversionResultQuery()
    var result: Double = 0
    var rate: Double = 0
    var isSuccessful: Bool = false
}

struct ParsedExchangeRatesConversionResultQuery: Codable {
    var currencyFrom: Currency = Currency()
    var currencyTo: Currency = Currency()
    var amount: Double = 0
}

extension ParsedExchangeRatesConversionResultResponse: Equatable {}

extension ParsedExchangeRatesConversionResultQuery: Equatable {}
