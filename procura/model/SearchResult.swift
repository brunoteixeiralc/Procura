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

func < (lhs: SearchResult, rhs:SearchResult) -> Bool{
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}

class SearchResult: Codable, CustomStringConvertible {
    
    var artistName = ""
    var trackName:String?
    var kind:String?
    var trackPrice:Double?
    var currency = ""
    var imageSmall = ""
    var imageLarge = ""
    var previewUrl = ""
    var trackViewUrl:String?
    var collectionName:String?
    var collectionViewUrl:String?
    var collectionPrice:Double?
    var itemPrice:Double?
    var itemGenre:String?
    var bookGenre:[String]?
    
    enum CodingKeys: String, CodingKey {
        
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case kind, artistName, currency
        case trackName, trackPrice, trackViewUrl
        case collectionName, collectionViewUrl, collectionPrice
    }
    
    var storeURL:String {
        return trackViewUrl ?? collectionViewUrl ?? ""
    }

    var price:Double {
        return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }
    
    var name: String{
        return trackName ?? collectionName ?? ""
    }
    
    var genre: String {
        if let genre = itemGenre {
            return genre
        } else if let genres = bookGenre {
            return genres.joined(separator: ", ")
        }
        return ""
    }
    
    var type: String {
        let kind = self.kind ?? "audiobook"
        switch kind {
            case "album": return "Álbum"
            case "audiobook": return "Livro de Áudio"
            case "book": return "Livro"
            case "ebook": return "E-Book"
            case "feature-movie": return "Filme"
            case "music-video": return "Clipe"
            case "podcast": return "Podcast"
            case "software": return "Aplicativo"
            case "song": return "Música"
            case "tv-episode": return "Episódio de TV"
            default: break
        }
        return "Desconhecido"
    }
    
    var description: String{
        return "Kind: \(kind ?? ""), Name: \(name), Artist name: \(artistName)"
    }
}
