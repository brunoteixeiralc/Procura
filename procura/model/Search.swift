//
//  Search.swift
//  procura
//
//  Created by Bruno Corrêa on 23/01/2018.
//  Copyright © 2018 Bruno Lemgruber. All rights reserved.
//

import Foundation
import UIKit

typealias SearchComplete = (Bool) -> Void

class Search {
    
    enum Category: Int {
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 3
        
        var type: String{
            switch self {
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .ebooks: return "ebook"
            }
        }
    }
    
    enum AnimationStyle {
        case slide
        case fade
    }
    
    enum State{
        case notSeachedYet
        case loading
        case noResults
        case results([SearchResult])
    }
    
    //é privado, porém pode somente 'setar' na classe Search. Nas outras classes somente leitura 'get'
    private(set) var state:State = .notSeachedYet
    private var dataTask: URLSessionDataTask? = nil
    
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete){
        if !text.isEmpty{
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            dataTask?.cancel()
            
            state = .loading
            
            let url = self.iTunesURL(searchText: text,category: category)
            print("URL: \(url)")
            
            let session = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
                
                var success = false
                var newState = State.notSeachedYet
                
                if let error = error as NSError?, error.code == -999{
                    return
                
                }else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200{
                    if let data = data{
                        var searchResults = self.parse(data: data)
                        if searchResults.isEmpty{
                            newState = .noResults
                        }else{
                            searchResults.sort(by: <)
                            newState = .results(searchResults)
                        }
                        success = true
                    }
                }

                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.state = newState
                    completion(success)
                }
            })
            dataTask?.resume()
        }
    }
    
    private func parse(data:Data) -> [SearchResult]{
        do{
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        }catch{
            print("Json error \(error)")
            return []
        }
    }
    
    private func iTunesURL(searchText: String, category: Category) -> URL{
        let kind = category.type
        
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = "https://itunes.apple.com/search?term=\(encodedText)&country=br&limit=200&entity=\(kind)"
        let url = URL(string:urlString)
        
        return url!
    }
}
