//
//  ContentView.swift
//  RickAndMorty
//
//  Created by Stefan Bayne on 11/28/22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var vm: CharacterViewModel
    
    init(vm: CharacterViewModel) {
        self._vm = StateObject(wrappedValue: CharacterViewModel(service: CharacterService()))
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
                                 */
                                AsyncImage(url: URL(string: item.image)) { phase in
                                    
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
                                        Color.indigo
                                            .overlay {
                                                ProgressView()
                                            }
                                    }
                                }.frame(width: 110, height: 120)
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                            .navigationBarTitle("Main Characters")
                            .navigationBarTitleDisplayMode(.inline)
                }
                .listStyle(.plain)
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
