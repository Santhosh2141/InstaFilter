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
//            .onChange(of: inputImage){ _ in
//                loadImage()
//            }
            .sheet(isPresented: $showingImagePicker){
                ImagePicker(image: $inputImage)
            }
        }
    }
    
    func save(){
        
    }
}

struct InstaFilterView_Previews: PreviewProvider {
    static var previews: some View {
        InstaFilterView()
    }
}
