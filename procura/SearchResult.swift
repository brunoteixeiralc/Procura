//
//  SearchResult.swift
//  procura
//
//  Created by Bruno Lemgruber on 09/01/2018.
//  Copyright © 2018 Bruno Lemgruber. All rights reserved.
//

import Foundation

class ResultArray: Codable{
    var resultCount = 0
    var results = [SearchResult]()
}

class SearchResult: Codable, CustomStringConvertible {
    
    var artistName = ""
    var trackName = ""
    //var collectionName = ""
    var kind = ""
    var collectionPrice = 0.0
    var trackPrice = 0.0
    var currency = ""
    var imageSmall = ""
    var imageLarge = ""
    var storeURL = ""
    var previewUrl = ""
    var genre = ""
    
    enum CodingKeys: String, CodingKey {
        
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case storeURL = "trackViewUrl"
        case genre = "primaryGenreName"
        case kind, artistName, trackName
        case trackPrice, currency
        case collectionPrice
        case previewUrl
    }
    
    var name: String{
        return trackName
    }
    
    var description: String{
        return "Kind: \(kind), Name: \(name), Artist name: \(artistName)"
    }
}
