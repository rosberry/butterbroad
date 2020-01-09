//
//  StorageService.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

protocol HasStorageService {
    var storageService: StorageServiceProtocol { get }
}

protocol StorageServiceProtocol: class {
    var events: [Event] { get set }
    func save()
}
