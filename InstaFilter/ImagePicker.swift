//
//  ImagePicker.swift
//  InstaFilter
//
//  Created by Santhosh Srinivas on 17/09/25.
//

import Foundation
import PhotosUI
import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable{
    
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate{
        // all UIKit views comes from NSObject. the second one acts the fucntionality on what to do.
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            // this is used the item like image/url or anything
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self){
                provider.loadObject(ofClass: UIImage.self){ image, _ in
                    // this doesnt know that it exactly is an image like how me mentioned in the makeUIViewController. so we do type conversion.
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        // use the coordinator class as a delegate for the image picker
        picker.delegate = context.coordinator
        return picker
        // this is the picker of image.
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
//    typealias UIViewControllerType = PHPickerViewController
    // thiis communicates bw UIKit and SiftUI
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class ImageSaver: NSObject{
    
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func writeToPhotoAlbum(image: UIImage){
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Finished Saving!")
        if let error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}
