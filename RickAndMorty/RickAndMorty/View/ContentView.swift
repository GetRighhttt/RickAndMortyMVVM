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
                        VStack(alignment: .leading){ // ** = bold
                            Text("**Name**: \(item.name)")
                            Text("**Status**: \(item.status)")
                            Text("**Gender**: \(item.gender)")
                            Text("**Created**: \(item.created)")
                            Text("**Origin**: \(item.origin.name)")
                            Text("**Location**: \(item.location.name)")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .padding(.horizontal, 4)
                    }
                    .navigationBarTitle("Rick & Morty Characters")
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
