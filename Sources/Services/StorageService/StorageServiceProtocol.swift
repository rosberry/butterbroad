//
//  StorageService.swift
//  ButterBroad
//
//  Created by Nick Tyunin on 17/05/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

protocol HasStorageService {
    var storageService: StorageServiceProtocol { get }
}

protocol StorageServiceProtocol: class {
    var events: [Event] { get set }
}
