//
//  ViewController.swift
//  procura
//
//  Created by Bruno Lemgruber on 09/01/2018.
//  Copyright © 2018 Bruno Lemgruber. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var searchBar:UISearchBar!
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.becomeFirstResponder()
        tableview.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        
        let cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableview.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        let cellNothingNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableview.register(cellNothingNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
    }
    
    func iTunesURL(searchText:String) -> URL{
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format:"https://itunes.apple.com/search?term=%@",encodedText)
        let url = URL(string:urlString)
        
        return url!
    }
    
    func performStoreReques(with url:URL) -> String?{
        do {
            return try String(contentsOf:url,encoding:.utf8)
        } catch {
            print("Error \(error.localizedDescription)")
            return nil
        }
    }
}

extension SearchViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        }else if searchResults.count == 0{
            return 1
        }else{
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if searchResults.count == 0{
            return tableView.dequeueReusableCell(withIdentifier:TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier:TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            cell.artistNameLabel!.text = searchResult.artistName
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0{
            return nil
        }else{
            return indexPath
        }
    }
}

extension SearchViewController: UISearchBarDelegate{
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty{
            
            searchBar.resignFirstResponder()
            
            hasSearched = true
            searchResults = []
            
            let url = iTunesURL(searchText: searchBar.text!)
            print("URL: \(url)")
            
            if let jsonString = performStoreReques(with: url){
                print("json: \(jsonString)")
            }
            
            tableview.reloadData()
        }
    }
}

