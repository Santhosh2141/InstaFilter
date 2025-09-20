//
//  InstaFilterView.swift
//  InstaFilter
//
//  Created by Santhosh Srinivas on 17/09/25.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import StoreKit

struct InstaFilterView: View {
    @State private var image: Image?
    @State private var inputImage: UIImage?
    @State private var originalCIImage: CIImage?
    @State private var processedImage: UIImage?     // for saving image
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 1.0
    @State private var intensityVisibility = true
    @State private var radiusVisibility = false
    @State private var showingImagePicker = false
    @State private var showingFilterSheet = false
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    let context = CIContext()
    // if we dont define it as CIFilter then its not possible to update it as it conforms to CIFilter and CISepiaTone
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    
    var disabledViews: Bool {
        (image == nil)
    }
    var body: some View {
        NavigationStack{
            VStack{
                ZStack{
                    Rectangle()
                        .fill(.thinMaterial)
                    HStack{
                        Text("Tap to select a picture")
                        Image(systemName: "hand.tap.fill")
                    }
                    .foregroundColor(.primary)
                    .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                    
                }
                .onTapGesture{
                    showingImagePicker = true
                }
                
                // adding another Slider for Radius
                VStack {
                    HStack{
                        Text("Intensity")
                            .foregroundColor(!intensityVisibility ? .secondary : .black)
                        Slider(value: $filterIntensity, in: 0...5)
                            .onChange(of: filterIntensity){ _ in
                                applyFilter()
                            }
                    }
                    .disabled(!intensityVisibility)
                    
                    HStack{
                        Text("Radius")
                            .foregroundColor(!radiusVisibility ? .secondary : .black)
                        Slider(value: $filterRadius, in: 0...10)
                            .onChange(of: filterRadius){ _ in
                                applyFilter()
                            }
                    }
                    .disabled(!radiusVisibility)
                }
                .padding(.vertical)
                .disabled(disabledViews)
                HStack{
                    Button("Change Filter"){
                        showingFilterSheet.toggle()
                    }
                    Spacer()
                    
                    if let image{
                        ShareLink(item: image, preview: SharePreview("Insta Filter Image", image: image)){
                            Label("Share Image", systemImage: "square.and.arrow.up")
                        }
                        Spacer()
                    }
                    Button("Save", action: save)
                    
                }
                .disabled(disabledViews)
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("InstaFilter")
            .onChange(of: inputImage){ _ in
                loadImage()
            }
            .sheet(isPresented: $showingImagePicker){
                ImagePicker(image: $inputImage)
            }
            // addded many filters and updating slider visibility
            .confirmationDialog("Select Filter", isPresented: $showingFilterSheet){
                Button("Crystallize"){
                    intensityVisibility = false
                    radiusVisibility = true
                    setFilter(CIFilter.crystallize())
                }
//                Button("Edges"){
//                    intensityVisibility = true
//                    radiusVisibility = false
//                    setFilter(CIFilter.edges())
//                }
                Button("Gaussian Blur"){
                    intensityVisibility = false
                    radiusVisibility = true
                    setFilter(CIFilter.gaussianBlur())
                }
                Button("Pixelate"){
                    intensityVisibility = true
                    radiusVisibility = false
                    setFilter(CIFilter.pixellate())
                }
                Button("Sepia Tone"){
                    intensityVisibility = true
                    radiusVisibility = false
                    setFilter(CIFilter.sepiaTone())
                }
                Button("UnSharp Mark"){
                    intensityVisibility = true
                    radiusVisibility = false
                    setFilter(CIFilter.unsharpMask())
                }
                Button("Vignette"){
                    intensityVisibility = true
                    radiusVisibility = true
                    setFilter(CIFilter.vignette())
                }
                Button("Hue Adjust"){
                    intensityVisibility = true
                    radiusVisibility = false
                    setFilter(CIFilter.hueAdjust())
                }
                Button("Red Monochrome"){
                    intensityVisibility = true
                    radiusVisibility = false
                    setFilter(CIFilter.colorMonochrome())
                }
                Button("Comic Effect"){
//                    intensityVisibility = true
//                    radiusVisibility = true
                    setFilter(CIFilter.comicEffect())
                }
                Button("Cancel", role: .cancel){}
            }
        }
    }
    
    func save(){
        guard let processedImage else { return }
        let imageSaver = ImageSaver()
        imageSaver.successHandler = {
            print("Success")
        }
        imageSaver.errorHandler = {
            print("Error: \($0.localizedDescription)")
        }
        // this saves the original image and not the filtered image
//        imageSaver.writeToPhotoAlbum(image: inputImage)
        imageSaver.writeToPhotoAlbum(image: processedImage)
        
        
    }
    
    func loadImage(){
        guard let inputImage = inputImage else { return }
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyFilter()
//        image = Image(uiImage: inputImage)
    }
    
    func applyFilter(){
//        currentFilter.intensity = Float(filterIntensity)
        let inputKey = currentFilter.inputKeys
        if inputKey.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKey.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius*100, forKey: kCIInputRadiusKey)
        }
        if inputKey.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterIntensity*10, forKey: kCIInputScaleKey)
        }
        if inputKey.contains(kCIInputCenterKey), let originalCIImage = originalCIImage {
            let center = CIVector(x: originalCIImage.extent.midX, y: originalCIImage.extent.midY)
            currentFilter.setValue(center, forKey: kCIInputCenterKey)
        }
        if inputKey.contains(kCIInputAngleKey){
            currentFilter.setValue(filterIntensity * .pi, forKey: kCIInputAngleKey)
        }
        if inputKey.contains(kCIInputColorKey){
            currentFilter.setValue(CIColor(red: filterIntensity/2, green: 0, blue: 0), forKey: kCIInputColorKey)
        }
        
        guard let outputImage = currentFilter.outputImage else {
            return
        }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }

        // convert that to a UIImage
        let uiImage = UIImage(cgImage: cgImage)

        // and convert that to a SwiftUI image
        image = Image(uiImage: uiImage)
        processedImage = uiImage
    }
    
    @MainActor func setFilter(_ filter: CIFilter){
        currentFilter = filter
        loadImage()
        
        filterCount += 1
        if filterCount >= 20 {
            requestReview()
            // this will throw an error as we need to call requestReview on the Main acotr which is the main function
        }
    }
}

struct InstaFilterView_Previews: PreviewProvider {
    static var previews: some View {
        InstaFilterView()
    }
}
