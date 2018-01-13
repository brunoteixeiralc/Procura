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
        static let loadingCell = "LoadingCell"
    }
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.becomeFirstResponder()
        tableview.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        
        let cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableview.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        let cellNothingNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableview.register(cellNothingNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        let cellLoadingNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableview.register(cellLoadingNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    }
    
    func iTunesURL(searchText:String) -> URL{
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format:"https://itunes.apple.com/search?term=%@&country=br&limit=200",encodedText)
        let url = URL(string:urlString)
        
        return url!
    }
    
    func performStoreReques(with url:URL) -> Data?{
        do {
            return try Data(contentsOf:url)
        } catch {
            print("Error \(error.localizedDescription)")
            showNetWorkError()
            return nil
        }
    }
    
    func parse(data:Data) -> [SearchResult]{
        do{
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        }catch{
            print("Json error \(error)")
            return []
        }
    }
    
    func showNetWorkError(){
        let alert = UIAlertController(title: "Opps...", message: "Houve um erro para acessar a loja da Itunes. Por favor tente novamente.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert,animated: true, completion: nil)
    }
}

extension SearchViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 1
        }else if !hasSearched {
            return 0
        }else if searchResults.count == 0{
            return 1
        }else{
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading{
            let cell = tableView.dequeueReusableCell(withIdentifier:TableViewCellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }else{
            if searchResults.count == 0{
                return tableView.dequeueReusableCell(withIdentifier:TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier:TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
                
                let searchResult = searchResults[indexPath.row]
                cell.nameLabel.text = searchResult.trackName
                cell.artistNameLabel!.text = "\(searchResult.artistName) (\(searchResult.type))"
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
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
            
            isLoading = true
            tableview.reloadData()
            
            hasSearched = true
            searchResults = []
            
            let url = self.iTunesURL(searchText: searchBar.text!)
            print("URL: \(url)")
            
            let queue = DispatchQueue.global()
            queue.async {
                if let data = self.performStoreReques(with: url){
                    self.searchResults = self.parse(data: data)
                    self.searchResults.sort(by: <)
                    
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.tableview.reloadData()
                    }
                    return
                }
            }
        }
    }
}

