//
//  ContentView.swift
//  InstaFilter
//
//  Created by Nicholas Johnson on 7/25/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI
import StoreKit

struct ContentView: View {
    @State private var showingFilters = false
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var selectedItem: PhotosPickerItem?
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    var context = CIContext()

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                PhotosPicker(selection: $selectedItem) {
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedItem, loadImage)
                
                Spacer()
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity, applyProcessing)
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change Filter", action: changeFilter)
                    
                    Spacer()
                    
                    // share
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("InstaFilter")
            .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                //
            }
        }
    }
    
    func changeFilter() {
        showingFilters = true
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }

            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
    
    func applyProcessing() {
        currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)

        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }

}

#Preview {
    ContentView()
}
