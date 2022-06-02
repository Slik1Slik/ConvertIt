//
//  ExchangeRatesDataTimeseriesRatesResultResponse.swift
//  ConvertIt
//
//  Created by Slik on 01.06.2022.
//

import Foundation

struct ExchangeRatesTimeseriesResultResponse: Codable {
    
    var base: String = ""
    var endDate: Date = Date()
    var rates: Dictionary<String, Dictionary<String, Double>>
    var startDate: Date = Date()
    var success: Bool = true
    var timeseries: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case base
        case endDate = "end_date"
        case rates
        case startDate = "start_date"
        case success
        case timeseries
    }
}

struct DailyExchangeRate {
    var date: Date = Date()
    var rate: Double = 1
}


struct ParsedExchangeRatesTimeseriesResultResponse {
    
    var currencyFrom: Currency = Currency()
    var currencyTo: Currency = Currency()
    var rates: [DailyExchangeRate] = []
    var startDate: Date = Date()
    var endDate: Date = Date()
}
