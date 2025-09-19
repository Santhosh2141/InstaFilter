//
//  InstaFilterView.swift
//  InstaFilter
//
//  Created by Santhosh Srinivas on 17/09/25.
//

import SwiftUI

struct InstaFilterView: View {
    @State private var image: Image?
    @State private var inputImage: UIImage?
    @State private var filterIntensity = 0.5
    @State private var showingImagePicker = false
    var body: some View {
        NavigationStack{
            VStack{
                ZStack{
                    Rectangle()
                        .fill(.gray)
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
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
                    Slider(value: $filterIntensity)
                }
                .padding(.vertical)
                
                HStack{
//                    Button("Change Filter", action: applyFilter)
                    Spacer()
                    
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
        }
    }
    
    func save(){
        
    }
    func loadImage(){
        guard let inputImage = inputImage else { return }
        
        image = Image(uiImage: inputImage)
    }
    
    func applyFilter(){
        guard let inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        let context = CIContext()
        let currentFilter = CIFilter.sepiaTone()
        currentFilter.inputImage = beginImage
        currentFilter.intensity = Float(filterIntensity)
        guard let outputImage = currentFilter.outputImage else { return }

        // attempt to get a CGImage from our CIImage
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }

        // convert that to a UIImage
        let uiImage = UIImage(cgImage: cgImage)

        // and convert that to a SwiftUI image
        image = Image(uiImage: uiImage)
    }
}

struct InstaFilterView_Previews: PreviewProvider {
    static var previews: some View {
        InstaFilterView()
    }
}
