//
//  CharacterService.swift
//  RickAndMorty
//
//  Created by Stefan Bayne on 11/28/22.
//

import Foundation

/**
 Here we're using a struct instead of a class because we don't need to observe anything in this example.
 
 The purpose of this service is only to exectue an api request. This is where we are going to use the Async and Await
 request.
 */
struct CharacterService {
    
    enum CharacterServiceError: Error {
        case failed
        case failedToDecode
        case invalidStatusCode
    }
    
    /**
     Must mark all async methods with async and throws because async allows us to throw an error.
     
     We also have to give our function some type of return type. In this case, we want our function to return an array of characters
     and we are going to get those characters from our character results
     */
    func fetchCharacters() async throws -> [Character] {
        /**
         URLSession new functionality by just calling the URL.
         
         data is the data we get back and response is the response that we get back.
         */
        let url = URL(string: "https://rickandmortyapi.com/api/character")
        let (data, response) = try await URLSession.shared.data(from: url!)
        
        /**
         Checking if status code is 200, and if it isn't, we want to throw an error.
         */
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            throw CharacterServiceError.invalidStatusCode
        }
        
        /**
         Now we need to decode our data and if tht is successful, then we return our character results. If it isn't,
         we throw an error.
         */
        let decodedData = try JSONDecoder().decode(CharacterResult.self, from: data)
        return decodedData.results
    }
}
