//
//  MediaContext.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import Foundation

//AppError enum which shows all possible errors
enum AppError: Error {
    case networkError(Error)
    case dataNotFound
    case jsonParsingError(Error)
    case invalidStatusCode(Int)
}

//Result enum to show success or failure
enum Result<T> {
    case success(T)
    case failure(AppError)
}

struct MediaContext {
    
    static var apiKEY: String {
        return Bundle.main.infoDictionary?["Pexels Key"] as! String
    }
    
    //dataRequest which sends request to given URL and convert to Decodable Object
    static func dataRequest<T: Decodable>(with url: String, objectType: T.Type, completion: @escaping (Result<T>) -> Void) {
        
        //create the url with NSURL
        guard let dataURL = URL(string: url) else { return }
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: dataURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        
        request.setValue(apiKEY, forHTTPHeaderField: "Authorization")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil else {
                completion(Result.failure(AppError.networkError(error!)))
                return
            }
            
            guard let data = data else {
                completion(Result.failure(AppError.dataNotFound))
                return
            }
            
            do {
                //create decodable object from data
                let decodedObject = try JSONDecoder().decode(objectType.self, from: data)
                completion(Result.success(decodedObject))
            } catch let error {
                completion(Result.failure(AppError.jsonParsingError(error as! DecodingError)))
            }
        })
        
        task.resume()
    }
    
}
