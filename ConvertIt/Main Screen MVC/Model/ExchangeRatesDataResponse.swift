//
//  ExchangeRatesDataResponse.swift
//  ConvertIt
//
//  Created by Slik on 01.05.2022.
//

import Foundation

struct ExchangeRatesDataResponse: Codable {
    var date: Date = Date()
    var info: ExchangeRatesDataResponseInfo = ExchangeRatesDataResponseInfo()
    var query: ExchangeRatesDataResponseQuery = ExchangeRatesDataResponseQuery()
    var result: Double = 0
    var success: Bool = false
}

struct ExchangeRatesDataResponseInfo: Codable {
    var rate: Double = 0
    var timestamp: Double = 0
}

struct ExchangeRatesDataResponseQuery: Codable {
    var amount: Double = 0
    var from: String = ""
    var to: String = ""
}

struct ParsedExchangeRatesDataResponse: Codable {
    var date: Date = Date()
    var timestamp: Double = 0
    var query: ParsedExchangeRatesDataQuery = ParsedExchangeRatesDataQuery()
    var result: Double = 0
    var rate: Double = 0
    var isSuccessful: Bool = false
}

struct ParsedExchangeRatesDataQuery: Codable {
    var currencyFrom: Currency = Currency()
    var currencyTo: Currency = Currency()
    var amount: Double = 0
}

extension ParsedExchangeRatesDataResponse: Equatable {}

extension ParsedExchangeRatesDataQuery: Equatable {}
