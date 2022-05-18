//
//  UserDataManager.swift
//  ConvertIt
//
//  Created by Slik on 09.05.2022.
//

import Foundation

class UserDataManager {
    
    static let shared: UserDataManager = UserDataManager()
    
    var currencies: [Currency] = []
    
    let currencyFromPlaceholder: Currency = Currency(identifier: "USD", localizedDescription: "Доллар США")
    let currencyToPlaceholder: Currency = Currency(identifier: "RUB", localizedDescription: "Российский рубль")
    
    let currencyAPI: ExchangeRatesAPI = ExchangeRatesDataAPI()
    
    private let currencyPopularityRatingFileURL = AppDirectoryURLs.getFullPath(forFileName: "CurrencyPopularityRating.json",
                                                                                      inDirectory: .documents)
    
    private let lastExchangeRatesDataResponseFileURL = AppDirectoryURLs.getFullPath(forFileName: "LastResponse.json",
                                                                                           inDirectory: .documents)
    
    func fetchLastExchangeRatesDataResponse() throws -> ParsedExchangeRatesDataResponse {
        guard let data = AppFileManager.readFileIfExists(at: lastExchangeRatesDataResponseFileURL) else {
            throw UserDataError.failedToFetchLastExchangeRatesDataResponse
        }
        guard let response = try? JSONManager.read(for: ParsedExchangeRatesDataResponse.self, from: data) else {
            throw UserDataError.failedToFetchLastExchangeRatesDataResponse
        }
        return response
    }
    
    func saveExchangeRatesDataResponse(_ response: ParsedExchangeRatesDataResponse) throws {
        do {
            try JSONManager.write(response, to: lastExchangeRatesDataResponseFileURL)
        } catch {
            throw UserDataError.failedToSaveLastExchangeRatesDataResponse
        }
    }
    
    func fetchCurrencyPopularityRating() throws -> [CurrencyPopularityRating] {
        var rating = [CurrencyPopularityRating]()
        guard AppFileStatusChecker.exists(file: currencyPopularityRatingFileURL) else {
            do {
                try createCurrencyPopularityRatingIfNeeded()
                rating = try fetchCurrencyPopularityRating()
            } catch let error {
                throw error
            }
            return rating
        }
        
        let ratingData = try? AppFileManager.readFile(at: currencyPopularityRatingFileURL)
        
        guard let ratingData = ratingData else {
            throw UserDataError.failedToFetchCurrencyPopularityRating
        }
        do {
            return try JSONManager.read(for: [CurrencyPopularityRating].self, from: ratingData)
        } catch {
            throw UserDataError.failedToFetchCurrencyPopularityRating
        }
    }
    
    func createCurrencyPopularityRatingIfNeeded() throws {
        guard !AppFileStatusChecker.exists(file: currencyPopularityRatingFileURL) else { return }
        do {
            try createCurrencyPopularityRatingBasedOnDefault()
        } catch {
            do {
                try createEmptyCurrencyPopularityRating()
            } catch let error {
                throw error
            }
        }
    }
    
    private func createCurrencyPopularityRatingBasedOnDefault() throws {
        guard let defaultRating = try? fetchDefaultCurrencyPopularityRating() else {
            throw UserDataError.failedToCreateCurrencyPopularityRating
        }
        do {
            try JSONManager.write(defaultRating, to: currencyPopularityRatingFileURL)
        } catch {
            throw UserDataError.failedToCreateCurrencyPopularityRating
        }
    }
    
    private func fetchDefaultCurrencyPopularityRating() throws -> [CurrencyPopularityRating] {
        guard let data = try? AppFileManager.loadBundledContent(fromFileNamed: "DefaultCurrencyPopularityRating", withExtension: "json") else {
            throw UserDataError.failedToFetchDefaultCurrencyPopularityRating
        }
        guard let defaultRaiting = try? JSONManager.read(for: [CurrencyPopularityRating].self, from: data) else {
            throw UserDataError.failedToFetchDefaultCurrencyPopularityRating
        }
        return defaultRaiting
    }
    
    private func createEmptyCurrencyPopularityRating() throws {
        let popularity = currencies.map { CurrencyPopularityRating(id: $0.identifier, popularity: 0) }
        do {
            try JSONManager.write(popularity, to: currencyPopularityRatingFileURL)
        } catch {
            throw UserDataError.failedToCreateCurrencyPopularityRating
        }
    }
    
    func increasePopularityRating(forId id: String) throws {
        guard let currenciesRatingData = try? AppFileManager.readFile(at: currencyPopularityRatingFileURL) else {
            throw UserDataError.failedToCreateCurrencyPopularityRating
        }
        guard var currenciesRating = try? JSONManager.read(for: [CurrencyPopularityRating].self, from: currenciesRatingData) else {
            throw UserDataError.failedToCreateCurrencyPopularityRating
        }
        for index in 0..<currenciesRating.count {
            if currenciesRating[index].id == id {
                currenciesRating[index].popularity += 1
            }
        }
        do {
            try JSONManager.write(currenciesRating, to: currencyPopularityRatingFileURL)
        } catch {
            throw UserDataError.failedToCreateCurrencyPopularityRating
        }
    }
    
    private func fetchCurrencies() throws -> [Currency] {
        let currenciesData = try? AppFileManager.loadBundledContent(fromFileNamed: "Currencies", withExtension: "json")
        guard let currenciesData = currenciesData else {
            throw UserDataError.failedToFetchCurrencies
        }
        guard let currencies = try? JSONManager.read(for: [Currency].self, from: currenciesData) else {
            throw UserDataError.failedToFetchCurrencies
        }
        return currencies
    }
    
    private init() {
        guard let currencies = try? fetchCurrencies() else {
            fatalError()
        }
        self.currencies = currencies
        try? createCurrencyPopularityRatingIfNeeded()
    }
}

enum UserDataError: Error {
    case failedToFetchCurrencies
    case failedToFetchLastExchangeRatesDataResponse
    case failedToSaveLastExchangeRatesDataResponse
    case failedToCreateCurrencyPopularityRating
    case failedToFetchCurrencyPopularityRating
    case failedToFetchDefaultCurrencyPopularityRating
    case failedToIncreaseRating
}
