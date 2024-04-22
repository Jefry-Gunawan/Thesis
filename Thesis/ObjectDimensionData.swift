//
//  ObjectDimensionData.swift
//  Thesis
//
//  Created by Jefry Gunawan on 22/04/24.
//

import Foundation

class ObjectDimensionData: ObservableObject {
    @Published var name: String
    @Published var width: String
    @Published var length: String
    @Published var height: String
    
    init() {
        self.name = "--"
        self.width = "--"
        self.length = "--"
        self.height = "--"
    }
    
    func reset() {
        self.name = "--"
        self.width = "--"
        self.length = "--"
        self.height = "--"
    }
}
