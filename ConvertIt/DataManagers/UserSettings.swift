//
//  UserSettings.swift
//  ConvertIt
//
//  Created by Slik on 9.05.2022.
//

import UIKit

@propertyWrapper
struct Defaults<T> {
    let key: String
    
    var storage: UserDefaults = .standard
    
    var wrappedValue: T?
    {
        get {
            storage.value(forKey: key) as? T
        }
        
        set{
            storage.set(newValue, forKey: key)
        }
    }
}

final class UserSettings
{
    static let shared: UserSettings = UserSettings()
    
    @Defaults<Bool>(key: "wasDataQueryEverMade") var wasDataQueryEverMade
    
    private let userDefaults = UserDefaults.standard
    
    var systemAppereanceMode: SystemAppereanceMode {
        get {
            let index = userDefaults.integer(forKey: SettingsKey.systemAppereanceMode.rawValue)
            return SystemAppereanceMode.allCases.first { $0.rawValue == index }!
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: SettingsKey.systemAppereanceMode.rawValue)
        }
    }
    
    private init() {
        registerUserSettings()
    }
    
    func registerUserSettings()
    {
        userDefaults.register(defaults: [SettingsKey.wasDataQueryEverMade.rawValue : false])
        userDefaults.register(defaults: [SettingsKey.systemAppereanceMode.rawValue : 0])
    }
    
    enum SettingsKey: String
    {
        case wasDataQueryEverMade
        case systemAppereanceMode
    }
}
