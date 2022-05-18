//
//  JSONManager.swift
//  ConvertIt
//
//  Created by Slik on 30.04.2021.
//

import Foundation

class JSONManager {
    
    static func read<T>(for type: T.Type, from url: URL) throws -> T where T: Decodable
    {
        let decoder = JSONDecoder()
        let formatter = DateConstants.dateFormatter
        
        guard let data = AppFileManager.readFileIfExists(at: url) else {
            throw AppFileManager.FileManagerError.failedToReadFile
        }
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        do {
             return try decoder.decode(T.self, from: data)
        } catch {
            throw JSONManagerError.fileDecodingFailed
        }
    }
    
    static func read<T>(for type: T.Type, from data: Data) throws -> T where T: Decodable
    {
        let decoder = JSONDecoder()
        let formatter = DateConstants.dateFormatter
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        decoder.dataDecodingStrategy = .base64
        
        do {
             return try decoder.decode(T.self, from: data)
        } catch {
            throw JSONManagerError.fileDecodingFailed
        }
    }
    
    static func read<T>(for type: T.Type, from url: URL, completion: @escaping (Result<T, JSONManagerError>) -> ()) where T: Decodable
    {
        let decoder = JSONDecoder()
        let formatter = DateConstants.dateFormatter
        
        guard let data = AppFileManager.readFileIfExists(at: url) else {
            completion(.failure(.resourseNotFount))
            return
        }
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        guard let result = try? decoder.decode(T.self, from: data) else {
            completion(.failure(.fileDecodingFailed))
            return
        }
        completion(.success(result))
    }
    
    static func read<T>(for type: T.Type, from data: Data, completion: @escaping (Result<T, JSONManagerError>) -> ()) where T: Decodable
    {
        let decoder = JSONDecoder()
        let formatter = DateConstants.dateFormatter
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        guard let result = try? decoder.decode(T.self, from: data) else {
            completion(.failure(.fileDecodingFailed))
            return
        }
        completion(.success(result))
    }
    
    static func write<T>(_ object: T, to url: URL) throws where T: Encodable
    {
        let encoder = JSONEncoder()
        let formatter = DateConstants.dateFormatter
        
        encoder.dateEncodingStrategy = .formatted(formatter)
        
        encoder.outputFormatting = [.prettyPrinted]
        
        guard let data = try? encoder.encode(object) else {
            throw AppFileManager.FileManagerError.failedToReadFile
        }
        
        do {
            try AppFileManager.writeFile(to: url, with: data)
        } catch let error {
            throw error
        }
    }
    
    static func write<T>(_ object: T, to url: URL, completion: (Result<Bool, JSONManagerError>) -> ()) where T: Encodable
    {
        let encoder = JSONEncoder()
        let formatter = DateConstants.dateFormatter
        
        encoder.dateEncodingStrategy = .formatted(formatter)
        
        encoder.outputFormatting = [.prettyPrinted]
        
        guard let data = try? encoder.encode(object) else {
            completion(.failure(.fileEncodingFailed))
            return
        }
        
        guard (try? AppFileManager.writeFile(to: url, with: data)) != nil else {
            completion(.failure(.fileEncodingFailed))
            return
        }
    }
    
    enum JSONManagerError: Error {
        case resourseNotFount
        case fileDecodingFailed
        case fileEncodingFailed
        
        var localizedDescription: String {
            switch self {
            case .resourseNotFount:
                return "Запрашиваемый ресурс не найден."
            case .fileDecodingFailed:
                return "Чтение данных оказалось неуспешным."
            case .fileEncodingFailed:
                return "Запись данных оказалась неуспешной."
            }
        }
    }
}
