//
//  Search.swift
//  procura
//
//  Created by Bruno Corrêa on 23/01/2018.
//  Copyright © 2018 Bruno Lemgruber. All rights reserved.
//

import Foundation

class Search {
    var searchResults: [SearchResult] = []
    var hasSearched = false
    var isLoading = false
    
    private var dataTask: URLSessionDataTask? = nil
    
    func performSearch(for text: String, category: Int){
        print("Procurando...")
    }
}
