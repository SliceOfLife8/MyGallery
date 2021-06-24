//
//  CollectionModel.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import Foundation

// MARK: - Collection
struct CollectionGeneric: Codable {
    let page, perPage: Int
    let collections: [Collection]
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case collections
        case totalResults = "total_results"
    }
}

// MARK: - Collection
struct Collection: Codable {
    let id, title: String
    let collectionDescription: String?
    let collectionPrivate: Bool
    let mediaCount, photosCount, videosCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case collectionDescription = "description"
        case collectionPrivate = "private"
        case mediaCount = "media_count"
        case photosCount = "photos_count"
        case videosCount = "videos_count"
    }
}
