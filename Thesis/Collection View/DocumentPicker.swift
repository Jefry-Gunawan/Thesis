//
//  DocumentPicker.swift
//  Thesis
//
//  Created by Jefry Gunawan on 01/05/24.
//

import Foundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var importSheet: Bool
    @Binding var importPreview: Bool
    @Binding var usdzURL: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.usdz])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                print("URL Imported : \(url)")
                
                do {
                    // Start accessing the security scoped resource
                    if url.startAccessingSecurityScopedResource() {
                        defer {
                            url.stopAccessingSecurityScopedResource()
                        }

                        // Copy the file to temporary storage
                        let fileManager = FileManager.default
                        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                        let destinationURL = tempDirectoryURL.appendingPathComponent(url.lastPathComponent)

                        try fileManager.copyItem(at: url, to: destinationURL)
                        print("File copied to temporary storage: \(destinationURL)")
                        parent.usdzURL = destinationURL
                    } else {
                        print("Could not access the security scoped resource.")
                    }
                } catch {
                    print("Error copying file: \(error.localizedDescription)")
                }
                
                parent.importPreview = true
            }
            parent.importSheet = false
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.importSheet = false
        }
    }
}
