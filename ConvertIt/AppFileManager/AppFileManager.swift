//
//  AppFileManager.swift
//  ConvertIt
//
//  Created by Slik on 30.04.2021.
//

import Foundation

class AppFileManager {
    
    static func readFile(at url: URL) throws -> Data
    {
        if !AppFileStatusChecker.exists(file: url) {
            do {
                try writeFile(to: url, with: Data())
            } catch {
                throw FileManagerError.failedToReadFile
            }
        }
        guard let data = FileManager.default.contents(atPath: url.path) else {
            throw FileManagerError.failedToReadFile
        }
        return data
    }
    
    static func readFileIfExists(at url: URL) -> Data?
    {
        if !AppFileStatusChecker.exists(file: url) {
            return nil
        }
        return FileManager.default.contents(atPath: url.path)
    }
    
    static func writeFile(to url: URL, with data: Data) throws
    {
        if !FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil) {
            throw FileManagerError.failedToWriteFile
        }
    }
    
    static func deleteFile(at url: URL) -> Bool
    {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            return false
        }
        return true
    }
    
    
    static func copyFile(at url: URL, to destinationURL: URL) -> Bool
    {
        try! FileManager.default.copyItem(at: url, to: destinationURL)
        return true
    }
    
    static func createFolder(at url: URL) -> Bool {
        ((try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)) != nil)
    }
    
    static func loadBundledContent(fromFileNamed name: String, withExtension fileExtension: String) throws -> Data {
        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: fileExtension
        ) else {
            throw FileManagerError.fileNotFound
        }
        do {
            let data = try readFile(at: url)
            return data
        } catch {
            throw FileManagerError.failedToLoadBundledContent
        }
    }
    
    enum FileManagerError: Error {
        case fileNotFound
        case failedToReadFile
        case failedToWriteFile
        case failedToLoadBundledContent
    }
}
