//
//  ContentView.swift
//  RickAndMorty
//
//  Created by Stefan Bayne on 11/28/22.
//

import SwiftUI

struct ContentView: View {
    
    /**
     View model instance.
     */
    @StateObject private var vm: CharacterViewModel
    /**
     Index of images
     */
    let index: Int
    
    init(vm: CharacterViewModel) {
        self._vm = StateObject(wrappedValue: CharacterViewModel(service: CharacterService()))
        self.index = 0
    }
    
    var body: some View {
        
        NavigationView {
            
            switch vm.state {
                /**
                 if successful, show data.
                 */
            case .success(let data):
                List {
                    ForEach(data,
                            id: \.id) { item in
                        
                        HStack(alignment: .top) {
                            
                            VStack {
                                
                                /**
                                 This is how we resize an image downloaded from a URL using AsyncImage. There are different
                                 ways we can go about manipulating this data.
                                 
                                 Here we demonstrate how to add images, use animations, and add delays to wait for those images to load in based on their index in the list.
                                 */
                                AsyncImage(url: URL(string: item.image), transaction: .init(animation: .spring().delay(Double(index) * 0.5))) { phase in
                                    
                                    if let image = phase.image {
                                        
                                        image.resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                    } else if phase.error != nil {
                                        
                                        Color.gray
                                            .opacity(0.75)
                                            .overlay {
                                                Image(systemName: "photo")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 30, weight: .bold))
                                            }
                                        
                                    } else { // progressview.
                                        Color.pink
                                            .overlay {
                                                ProgressView()
                                            }
                                    }
                                }
                                .frame(width: 110, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .transition(.opacity.combined(with: .scale))
                            }
                            
                            VStack(alignment: .leading) { // ** = bold
                                
                                Text("**Name**: \(item.name)")
                                    .font(.headline)
                                Text("**Status**: \(item.status)")
                                    .font(.subheadline)
                                Text("**Gender**: \(item.gender)")
                                    .font(.subheadline)
                                Text("**Origin**: \(item.origin.name)")
                                    .font(.subheadline)
                                Text("**Location**: \(item.location.name)")
                                    .font(.subheadline)
                                Text("**Created**: \(item.created)")
                                    .font(.subheadline)
                                
                            }
                        }
                        .padding()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .navigationBarTitle("Main Rick & Morty Characters")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .listStyle(.grouped)
                /**
                 if loading, show a progress circle.
                 */
            case .loading:
                ProgressView()
                /**
                 or else, show nothing..
                 */
            default:
                EmptyView()
            }
            
        }.task {
            await vm.getCharacters()
        } /**
           Create an alert when there is an error, and also be sure to state the state of the error.
           */
        .alert("Error",
               isPresented: $vm.hasError, presenting: vm.state) { detail in
            
            Button("Retry") {
                Task {
                    await vm.getCharacters()
                }
            }
        } message: { detail in
            if case let .failed(error) = detail {
                Text(error.localizedDescription)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(vm: CharacterViewModel(service: CharacterService()))
    }
}
