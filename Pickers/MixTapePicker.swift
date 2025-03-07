//
//  MixTapePicker.swift
//  Mixtapes
//
//  Created by Swanand Tanavade on 03/25/23.
//

import Foundation
import UIKit
import SwiftUI
import MobileCoreServices
import AVFoundation
import CoreData

struct MixTapePicker: UIViewControllerRepresentable {
    
    var nameofTape: String
    @Binding var mixTapePicked: Bool
    let moc: NSManagedObjectContext

    func makeUIViewController(context: UIViewControllerRepresentableContext<MixTapePicker>) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeAudio)], in: .open)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<MixTapePicker>) {
        
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate{
        
        var parent: MixTapePicker
        
        
        init (parent_param: MixTapePicker) {
            self.parent = parent_param
            

        }
        
        internal func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){
            // urls of picked files wil be in array urls
            
            let newMixTape = MixTape(context: parent.moc)
            newMixTape.title = parent.nameofTape
            
            var counter: Int16 = 0
            for url in urls {

                let song = Song(context: parent.moc)
                let didStartAccessing = url.startAccessingSecurityScopedResource()
                if didStartAccessing {
                    song.urlData = try! url.bookmarkData()
                    url.stopAccessingSecurityScopedResource()
                } else {
                    print("Could not access url")
                }
                song.name = url.deletingPathExtension().lastPathComponent
                song.positionInTape = counter
                newMixTape.addToSongs(song)
                counter += 1
            }
            
            newMixTape.numberOfSongs = counter
            do {
                try parent.moc.save()
            } catch {
                print(error)
            }
            parent.mixTapePicked.toggle()
                

        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent_param: self)
    }
    


    
    typealias UIViewControllerType = UIDocumentPickerViewController

}


