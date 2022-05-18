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
        //let semaphore = DispatchSemaphore(value: 0)
        
        guard let url = createURL(currencyFrom: currencyFromCode, currencyTo: currencyToCode, amount: amount) else {
            completion(.failure(ExchangeRatesDataAPIError.failedToCreateURL))
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        
        request.httpMethod = "GET"
        
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        
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
            //semaphore.signal()
        }
        currentTask = task
        currentTask!.resume()
        //semaphore.wait()
    }
    
    func fetch(completion: @escaping (DataTaskResult) -> Void) {
        
    }
    
    func cancelCurrentTask() {
        currentTask?.cancel()
    }
}

extension ExchangeRatesDataAPI {
    
    private func createURL(currencyFrom: String, currencyTo: String, amount: Double) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.apilayer.com"
        components.path = "/exchangerates_data/convert"
        components.queryItems = [
            URLQueryItem(name: "to", value: currencyTo),
            URLQueryItem(name: "from", value: currencyFrom),
            URLQueryItem(name: "amount", value: amount.description)
        ]
        
        return components.url
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
