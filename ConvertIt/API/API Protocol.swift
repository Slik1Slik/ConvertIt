//
//  API Protocol.swift
//  ConvertIt
//
//  Created by Slik on 07.05.2022.
//

import Foundation

protocol ExchangeRatesAPI {
    
    typealias DataTaskResult = Result<Data, ExchangeRatesDataAPIError>
    
    func resultOfConverting(amount: Double,
                            ofCurrencyAtCode currencyFromCode: String,
                            toCurrencyAtCode currencyToCode: String,
                            completion: @escaping (Result<Data, ExchangeRatesDataAPIError>) -> Void) -> Void
    
    func historicalRates(between startDate: Date,
                         and endDate: Date,
                         currencyFromCode: String,
                         currencyToCode: String,
                         completion: @escaping (DataTaskResult) -> Void)
    
    func fetch(completion: @escaping (Result<Data, ExchangeRatesDataAPIError>) -> Void)
    
    func cancelCurrentTask()
}
