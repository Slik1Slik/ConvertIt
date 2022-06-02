//
//  NetworkService.swift
//  ConvertIt
//
//  Created by Slik on 11.05.2022.
//

import Foundation
import Network
import UIKit

class NetworkService {
    
    static let shared: NetworkService = NetworkService()
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor = NWPathMonitor()
    
    private var isPathUpdateInitial: Bool = true
    
    private(set) lazy var isConnectionAvailable: Bool = monitor.currentPath.status == .satisfied {
        didSet {
            guard isConnectionAvailable != oldValue else { return }
            if isPathUpdateInitial {
                NotificationCenter.default.post(name: Notifications.internetConnectionDidBecomeMonitoredNotification, object: nil)
                isPathUpdateInitial = false
            } else {
                let notification = isConnectionAvailable ? Notifications.internetConnectionDidRestoreNotification : Notifications.internetConnectionDidBecomeLostNotification
                NotificationCenter.default.post(name: notification, object: nil)
            }
        }
    }
    
    private(set) var connectionType: NWInterface.InterfaceType? {
        didSet {
            NotificationCenter.default.post(name: Notifications.internetConnectionTypeDidChangeNotification, object: nil)
        }
    }
    
    func startMonitoringConnection() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isConnectionAvailable = path.status == .satisfied
                self.connectionType = path.connectionType
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoringConnection() {
        monitor.cancel()
    }
    
    private init() { }
    
    deinit {
        stopMonitoringConnection()
    }
}

extension NetworkService {
    struct Notifications {
        static let internetConnectionDidBecomeMonitoredNotification: Notification.Name = .init(rawValue: "internetConnectionDidBecomeMonitoredNotification")
        static let internetConnectionDidBecomeLostNotification: Notification.Name = .init(rawValue: "internetConnectionDidBecomeLost")
        static let internetConnectionDidRestoreNotification: Notification.Name = .init(rawValue: "internetConnectionDidRestore")
        static let internetConnectionTypeDidChangeNotification: Notification.Name = .init(rawValue: "internetConnectionTypeDidChange")
    }
}

extension NWPath {
    var connectionType: NWInterface.InterfaceType? {
        var type: NWInterface.InterfaceType?
        for interface in self.availableInterfaces {
            if self.usesInterfaceType(interface.type) {
                type = interface.type
                break
            }
        }
        return type
    }
}
