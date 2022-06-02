//
//  ExchangeRatesDataAPI.swift
//  ConvertIt
//
//  Created by Slik on 01.05.2022.
//

import Foundation

final class ExchangeRatesDataAPI: ExchangeRatesAPI {
    
    typealias DataTaskResult = Result<Data, ExchangeRatesDataAPIError>
    
    private var currentTask: URLSessionDataTask?
    
    private let apiKey: String = "s0U3JDi0d032zOYya8IpBJYW4t2RjUNG"
    
    func resultOfConverting(amount: Double, ofCurrencyAtCode currencyFromCode: String, toCurrencyAtCode currencyToCode: String, completion: @escaping (DataTaskResult) -> Void) -> Void {
        
        let queryItems = [
            URLQueryItem(name: "to", value: currencyToCode),
            URLQueryItem(name: "from", value: currencyFromCode),
            URLQueryItem(name: "amount", value: amount.description)
        ]
        
        guard let url = createURL(path: "/exchangerates_data/convert",
                                  queryItems: queryItems)
        else {
            completion(.failure(ExchangeRatesDataAPIError.failedToCreateURL))
            return
        }
        
        let request = createURLRequest(for: url)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            self?.handleDataTaskResult(data: data,
                                       response: response,
                                       error: error,
                                       completion: completion)
        }
        currentTask = task
        currentTask!.resume()
    }
    
    func historicalRates(between startDate: Date, and endDate: Date, currencyFromCode: String, currencyToCode: String, completion: @escaping (DataTaskResult) -> Void) {
        
        let queryItems = [
            URLQueryItem(name: "start_date", value: startDate.string(format: DateConstants.dateFormat)),
            URLQueryItem(name: "end_date", value: endDate.string(format: DateConstants.dateFormat)),
            URLQueryItem(name: "base", value: currencyFromCode),
            URLQueryItem(name: "symbols", value: currencyToCode),
        ]
        
        guard let url = createURL(path: "/exchangerates_data/timeseries",
                                  queryItems: queryItems)
        else {
            completion(.failure(ExchangeRatesDataAPIError.failedToCreateURL))
            return
        }
        
        let request = createURLRequest(for: url)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            self?.handleDataTaskResult(data: data,
                                       response: response,
                                       error: error,
                                       completion: completion)
        }
        currentTask = task
        currentTask!.resume()
    }
    
    func fetch(completion: @escaping (DataTaskResult) -> Void) {
        
    }
    
    func cancelCurrentTask() {
        currentTask?.cancel()
    }
}

extension ExchangeRatesDataAPI {
    
    private func createURL(path: String, queryItems: [URLQueryItem]) -> URL? {
        
        var components = URLComponents()
        
        components.scheme = "https"
        components.host = "api.apilayer.com"
        components.path = path
        components.queryItems = queryItems
        
        return components.url
    }
    
    private func createURLRequest(for url: URL) -> URLRequest {
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        
        request.httpMethod = "GET"
        
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        
        return request
    }
}

extension ExchangeRatesDataAPI {
    
    private func handleDataTaskResult(data: Data?, response: URLResponse?, error: Error?, completion: @escaping (DataTaskResult) -> Void) {
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
}

enum ExchangeRatesDataAPIError: Error {
    case badRequest
    case unauthorized
    case notFound
    case requestLimitExceeded
    case serverError
    case failedToCreateURL
    case notHTTPResponse
    case unknownServersideError(Error)
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .badRequest:
            return "Запрос к серверу не может быть обработан. Пожалуйста, проверьте правильность введенных данных и повторите попытку."
        case .unauthorized:
            return "Запрос к серверу не может быть обработан. Пожалуйста, проверьте правильность введенных данных или повторите попытку позднее."
        case .notFound:
            return "Запрашиваемые данные по валютам не существуют. Пожалуйста, проверьте правильность введенных данных и повторите попытку."
        case .requestLimitExceeded:
            return "Превышен лимит запросов к серверу."
        case .serverError:
            return "Возникла неизвестная ошибка на сервере. Пожалуйста, повторите попытку позднее."
        case .failedToCreateURL:
            return "Не удалось создать корректный запрос. Пожалуйста, проверьте правильность введенных данных."
        case .notHTTPResponse:
            return "Неизвестный формат ответа сервера. Пожалуйста, повторите попытку позднее."
        case .unknownServersideError(let error):
            return error.localizedDescription
        case .unknownError:
            return "Возникла неизвестная ошибка на сервере. Пожалуйста, повторите попытку позднее."
        }
    }
    
    static func errorFor(statusCode: Int) -> Self {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 404: return .notFound
        case 429: return .requestLimitExceeded
        default:
            guard (500...599).contains(statusCode) else {
                return .unknownError
            }
            return .serverError
        }
    }
}



extension ExchangeRatesDataAPIError: Equatable {
    static func == (lhs: ExchangeRatesDataAPIError, rhs: ExchangeRatesDataAPIError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
}
