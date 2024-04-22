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
    var snapshotProject: Data
    
    init(id: UUID, name: String, data: Data, roomLength: Float, roomWidth: Float, snapshotProject: Data) {
        self.id = id
        self.name = name
        self.data = data
        self.roomLength = roomLength
        self.roomWidth = roomWidth
        self.snapshotProject = snapshotProject
    }
}

@Model
final class ItemCollection {
    var id: UUID
    var name: String
    var data: Data
    var dataURL: String!
    var snapshotItem: Data
    
    init(id: UUID, name: String, data: Data, dataURL: String!, snapshotItem: Data) {
        self.id = id
        self.name = name
        self.data = data
        self.dataURL = dataURL
        self.snapshotItem = snapshotItem
    }
}
