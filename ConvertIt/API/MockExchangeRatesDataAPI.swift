//
//  MockExchangeRatesDataAPI.swift
//  ConvertIt
//
//  Created by Slik on 17.05.2022.
//

import Foundation


final class MockExchangeRatesAPI: ExchangeRatesAPI {
    
    typealias DataTaskResult = Result<Data, ExchangeRatesDataAPIError>
    
    private var currentTask: URLSessionDataTask?
    
    func resultOfConverting(amount: Double, ofCurrencyAtCode currencyFromCode: String, toCurrencyAtCode currencyToCode: String, completion: @escaping (DataTaskResult) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            switch amount {
            case 200:
                completion(.success(Data()))
            case 404:
                completion(.failure(ExchangeRatesDataAPIError.notFound))
            default:
                completion(.failure(ExchangeRatesDataAPIError.unknownServersideError(URLError(.unknown))))
            }
        }
    }
    
    func fetch(completion: @escaping (DataTaskResult) -> Void) {
        
    }
    
    func cancelCurrentTask() {
        currentTask?.cancel()
    }
    
    private func createURL(scheme: String, host: String, path: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        return components.url
    }
}

/*
 
 func resultOfConverting(amount: Double, ofCurrencyAtCode currencyFromCode: String, toCurrencyAtCode currencyToCode: String, completion: @escaping (Result<Data, ExchangeRatesDataAPIError>) -> Void) {

     let url = createURL(scheme: "https",
                         host: "webhook.site",
                         path: "/1afcc04e-5da8-4328-8558-15ff176b58e9")!

     var request = URLRequest(url: url, timeoutInterval: Double.infinity)

     request.httpMethod = "GET"

     let task = URLSession.shared.dataTask(with: request) { data, response, error in
         guard let response = response, let httpResponse = response as? HTTPURLResponse else {
             if let error = error {
                 completion(.failure(ExchangeRatesDataAPIError.unknownServersideError(error)))
             } else if (response as? HTTPURLResponse) == nil {
                 completion(.failure(ExchangeRatesDataAPIError.notHTTPResponse))
             } else {
                 completion(.failure(.unknownError))
             }
             return
         }
         guard (200...299).contains(httpResponse.statusCode) else {
             completion(.failure(ExchangeRatesDataAPIError.errorFor(statusCode: httpResponse.statusCode)))
             return
         }
         guard let data = data, data != Data() else {
             completion(.failure(ExchangeRatesDataAPIError.unknownError))
             return
         }
         completion(.success(data))
     }
     currentTask = task
     currentTask!.resume()
 }
 
 */
