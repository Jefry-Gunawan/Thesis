//
//  Item.swift
//  Thesis
//
//  Created by Jefry Gunawan on 30/01/24.
//

import Foundation
import SwiftData

@Model
final class Project {
    var id: UUID
    var name: String
    var data: Data
    var roomLength: Float
    var roomWidth: Float
    
    init(id: UUID, name: String, data: Data, roomLength: Float, roomWidth: Float) {
        self.id = id
        self.name = name
        self.data = data
        self.roomLength = roomLength
        self.roomWidth = roomWidth
    }
}

@Model
final class ItemCollection {
    var id: UUID
    var name: String
    var data: Data
    var entityData: Data
    
    init(id: UUID, name: String, data: Data, entityData: Data) {
        self.id = id
        self.name = name
        self.data = data
        self.entityData = entityData
    }
}
