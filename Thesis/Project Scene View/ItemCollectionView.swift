//
//  ItemCollectionView.swift
//  Thesis
//
//  Created by Jefry Gunawan on 11/02/24.
//

import Foundation
import SwiftUI
import SwiftData

struct ItemCollectionView: View {
    // Database
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ItemCollection]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.regularMaterial)
                
                LazyVGrid(columns: columns, content: {
                    ForEach(1..<6) { i in
                        ItemBoxView()
                    }
                })
            }
            .frame(width: 600, height: 600)
        }
    }
}

struct ItemBoxView: View {
    @Environment(\.colorScheme) var colorScheme

    var textColor: Color {
        if colorScheme == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
        }
        .frame(width: 50, height: 50)
    }
}

//#Preview(body: {
//    ItemCollectionView()
//})
