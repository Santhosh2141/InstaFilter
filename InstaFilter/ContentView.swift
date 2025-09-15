//
//  ContentView.swift
//  InstaFilter
//
//  Created by Santhosh Srinivas on 15/09/25.
//

import SwiftUI

struct ContentView: View {
    @State private var blurAmount = 0.0
//    {
        // when we check the Swift Doc for @State. there is a wrappedValue.
        // what this does is, the setter is non mutating.
        // so when we use $ to update the value it doesnt actully change the exact value. it tells SwiftUI to store the updated value.
//        didSet{
//            print(blurAmount)
//        }
//    }
    
    @State private var showingConfirm = false
    @State private var backgroundColor = Color.white
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
                .blur(radius: blurAmount)
            Slider(value: $blurAmount, in: 0...20)
                .onChange(of: blurAmount){ newValue in
                    print("New value is \(newValue)")
                }
            Button("Random Blur"){
                blurAmount = Double.random(in: 0...20)
            }
            Button("Show Confirmation"){
                showingConfirm.toggle()
            }
            .frame(width: 500, height: 500)
            .background(backgroundColor)
            .confirmationDialog("Change background", isPresented: $showingConfirm) {
                Button("Red") { backgroundColor = .red }
                Button("Green") { backgroundColor = .green }
                Button("Blue") { backgroundColor = .blue }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Select a new color")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
