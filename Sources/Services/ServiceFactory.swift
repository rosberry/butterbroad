//
//  ServiceFactory.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

typealias HasServices = HasStorageService

var Services: HasServices = MainServicesFactory() // swiftlint:disable:this identifier_name

final class MainServicesFactory: HasStorageService {
    let storageService: StorageServiceProtocol = UserDefaults.standard
}
