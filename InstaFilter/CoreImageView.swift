//
//  CoreImageView.swift
//  InstaFilter
//
//  Created by Santhosh Srinivas on 16/09/25.
//

import CoreImage
import PhotosUI
import CoreImage.CIFilterBuiltins
import SwiftUI
// for leaving app review
import StoreKit

// UIKit has a parentView called UIVIew
// it also has UIViewCOntroller to bring all work to bring funcs to life.
// it also has delegation to decide what happens when smth is clicked elsewhere
struct CoreImageView: View {
    @State private var image: Image?
    @State private var inputImage: UIImage?
    @State private var showingImage = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @Environment(\.requestReview) var requestReview
    // SwiftUI gives 3 image views
//    We can create a UIImage from a CGImage, and create a CGImage from a UIImage.
//    We can create a CIImage from a UIImage and from a CGImage, and can create a CGImage from a CIImage.
//    We can create a SwiftUI Image from both a UIImage and a CGImage.
    var body: some View {
        let example = Image("FtfYJsJaMAAxaSC")
        VStack{
            image?
                .resizable()
                .scaledToFit()
//            ContentUnavailableView {
//                Label("No snippets", systemImage: "swift")
//            } description: {
//                Text("You don't have any saved snippets yet.")
//            } actions: {
//                Button("Create Snippet") {
//                    // create a snippet
//                }
//                .buttonStyle(.borderedProminent)
//            }
            
            Button("Select Image"){
                showingImage = true
            }
//            PhotosPicker("Select a picture", selection: $pickerItem, matching: .images)
//            selectedImage?
//                .resizable()
//                .scaledToFit()
            
//            ShareLink(item: URL(string: "https://www.hackingwithswift.com")! ,subject: Text("Learn Swift"), message: Text("Learn 100 days of SwiftUI"))
            ShareLink(item: URL(string: "https://www.hackingwithswift.com")!) {
                Label("Spread the word about Swift", systemImage: "swift")
            }
            ShareLink(item: example, preview: SharePreview("MS Dhoni", image: example)) {
                Label("Click to share", systemImage: "figure.cricket")
            }
            // it works. but its not ideal to let user to dictate.
            // so its better to call this after a time frame like after doing some action many times.
            Button("Leave a review") {
                requestReview()
            }
            Button("Save image"){
                guard let inputImage = inputImage else {
                    return
                }
                let imageSaver = ImageSaver()
                imageSaver.writeToPhotoAlbum(image: inputImage)
            }
        }
//        .onAppear(perform: loadImg)
        .sheet(isPresented: $showingImage){
            ImagePicker(image: $inputImage)
        }
        .onChange(of: inputImage){ _ in
            loadImg1()
        }
//        .onChange(of: pickerItem){
//            Task{
//                selectedImage = try await pickerItem?.loadTransferable(type: Image.self)
//            }
//        }
    }
    
    func loadImg(){
        // CGImage, CIImage and UIImage cant be used in a view
//        image = Image("FtfYJsJaMAAxaSC")
        guard let inputImage = UIImage(named: "FtfYJsJaMAAxaSC") else {
            return
        }
        let beginImage = CIImage(image: inputImage)
        
        let context = CIContext()
//        let currentFilter = CIFilter.sepiaTone()
//        let currentFilter = CIFilter.pixellate()
//        let currentFilter = CIFilter.crystallize()
        let currentFilter = CIFilter.twirlDistortion()
        
        let amount = 1.0
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(amount, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(amount*200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(amount*10, forKey: kCIInputScaleKey)
        }
        currentFilter.inputImage = beginImage
//        currentFilter.intensity = 1
//        currentFilter.scale = 50
//        currentFilter.radius = 50
//        currentFilter.radius = 400
//        currentFilter.center = CGPoint(x: inputImage.size.width / 2, y: inputImage.size.height / 2)
        
        // get a CIImage from our filter or exit if that fails
        guard let outputImage = currentFilter.outputImage else { return }

        // attempt to get a CGImage from our CIImage
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }

        // convert that to a UIImage
        let uiImage = UIImage(cgImage: cgImage)

        // and convert that to a SwiftUI image
        image = Image(uiImage: uiImage)
    }
    func loadImg1(){
        // CGImage, CIImage and UIImage cant be used in a view
//        image = Image("FtfYJsJaMAAxaSC")
        guard let inputImage = inputImage else {
            return
        }
        image = Image(uiImage: inputImage)
        // this tells what methods to call when saving is complete
        // 1st is image, 2nd(NSObject class) is object, 3rd is method(name) in the obj, 4th is anything and passed back when method is called in the obj
        
        
    }
}

struct CoreImageView_Previews: PreviewProvider {
    static var previews: some View {
        CoreImageView()
    }
}
