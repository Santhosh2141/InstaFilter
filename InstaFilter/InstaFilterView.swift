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
    @State private var filterIntensity = 0.5
    @State private var showingImagePicker = false
    @State private var showingFilterSheet = false
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    let context = CIContext()
    // if we dont define it as CIFilter then its not possible to update it as it conforms to CIFilter and CISepiaTone
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    var body: some View {
        NavigationStack{
            VStack{
                ZStack{
                    Rectangle()
                        .fill(.thinMaterial)
                    Text("Tap to select a picture")
                        .foregroundColor(.primary)
                        .font(.headline)
                    image?
                        .resizable()
                        .scaledToFit()
                    
                }
                .onTapGesture{
                    showingImagePicker = true
                }
                
                HStack{
                    Text("Intensity")
                    Slider(value: $filterIntensity, in: 0...5)
                        .onChange(of: filterIntensity){ _ in
                            applyFilter()
                        }
                }
                .padding(.vertical)
                
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
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("InstaFilter")
            .onChange(of: inputImage){ _ in
                loadImage()
            }
            .sheet(isPresented: $showingImagePicker){
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select Filter", isPresented: $showingFilterSheet){
                Button("Crystallize"){setFilter(CIFilter.crystallize())}
                Button("Edges"){setFilter(CIFilter.edges())}
                Button("Gaussian Blur"){setFilter(CIFilter.gaussianBlur())}
                Button("Pixelate"){setFilter(CIFilter.pixellate())}
                Button("Sepia Tone"){setFilter(CIFilter.sepiaTone())}
                Button("UnSharp Mark"){setFilter(CIFilter.unsharpMask())}
                Button("Vignette"){setFilter(CIFilter.vignette())}
                Button("Cancel", role: .cancel){}
            }
        }
    }
    
    func save(){
        
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
        if inputKey.contains(kCIInputIntensityKey){
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        } else if inputKey.contains(kCIInputRadiusKey){
            currentFilter.setValue(filterIntensity*200, forKey: kCIInputRadiusKey)
        } else if inputKey.contains(kCIInputScaleKey){
            currentFilter.setValue(filterIntensity*10, forKey: kCIInputScaleKey)
        } else if inputKey.contains(kCIInputCenterKey), let originalCIImage = originalCIImage {
            let center = CIVector(x: originalCIImage.extent.midX, y: originalCIImage.extent.midY)
            currentFilter.setValue(center, forKey: kCIInputCenterKey)
        }
        
        guard let outputImage = currentFilter.outputImage else {
            return
        }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }

        // convert that to a UIImage
        let uiImage = UIImage(cgImage: cgImage)

        // and convert that to a SwiftUI image
        image = Image(uiImage: uiImage)
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
    func saveImage(){
        
    }
}

struct InstaFilterView_Previews: PreviewProvider {
    static var previews: some View {
        InstaFilterView()
    }
}
