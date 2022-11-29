//
//  CharacterViewModel.swift
//  RickAndMorty
//
//  Created by Stefan Bayne on 11/28/22.
//

import Foundation

/**
 We created our class for our viewmodel because we need to observe data from our api and bind the data to our views.
 
 This is where if there is an update to our views, this class will observe that and make the necessary changes.
 
 We annotate the class with Main Actor so we publish any UI changes to the main thread.
 */
@MainActor
class CharacterViewModel: ObservableObject {
    
    /**
     We create an enum class here to tell us the current state of our view model.
     If the state is successful, we pass in our data and our list of characters. if not, we throw
     an error.
     */
    enum State {
        case na
        case loading
        case success(data: [Character])
        case failed(error: Error)
    }
    
    /**
     we set the initial state to not applicable or not here essentially, and we use @Published property and makr it as private set
     and we want the view to be able to access the view model but not be able to change it.
     */
    @Published private(set) var state: State = .na
    
    @Published var hasError: Bool = false
    
    /**
     We are going to use dependency injection to inject our service into our ViewModel
     */
    private let service: CharacterService
    
    init(service: CharacterService) {
        self.service = service
    }
    
    /**
     Now we create our method to get the list of characters from our results. We set the initial state to loading.
     */
    func getCharacters() async {
        
        self.state = .loading
        self.hasError = false
        
        do {
            let characters = try await service.fetchCharacters()
            self.state = .success(data: characters)
        } catch {
            self.state = .failed(error: error)
            self.hasError = true
        }
    }
}
