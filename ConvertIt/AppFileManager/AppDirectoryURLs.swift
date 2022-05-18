//
//  AppDirectoryURLs.swift
//  ConvertIt
//
//  Created by Slik on 30.04.2021.
//

import Foundation

class AppDirectoryURLs {
    
    static func documentsDirectoryURL() -> URL {
        
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
    
    static func tempDirectoryURL() -> URL {
        return FileManager.default.temporaryDirectory
    }
    
    static func getURL(for directory: AppDirectory) -> URL {
        switch directory
        {
        case .documents:
            return documentsDirectoryURL()
            
        case .temp:
            return tempDirectoryURL()
        }
    }
    
    static func getFullPath(forFileName name: String, inDirectory directory: AppDirectory) -> URL {
        return getURL(for: directory).appendingPathComponent(name)
    }
    
    enum AppDirectory : String
    {
        case documents = "Documents"
        case temp = "tmp"
    }
}
