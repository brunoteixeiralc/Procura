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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    private let search = Search()
    var landscapeVC: LandscapeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.becomeFirstResponder()
        tableview.contentInset = UIEdgeInsetsMake(108, 0, 0, 0)
        
        let cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableview.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        let cellNothingNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableview.register(cellNothingNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        let cellLoadingNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableview.register(cellLoadingNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular:
            hideLandscape(with: coordinator)
        case .unspecified: break
        }
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator){
        
        guard landscapeVC == nil else { return }
        
        landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeVC{
            controller.search = search
            controller.view.frame = view.bounds
            view.addSubview(controller.view)
            addChildViewController(controller)
            
            coordinator.animate(alongsideTransition: { (_) in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil{
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { (_) in
                controller.didMove(toParentViewController: self)
            })
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator){
        
        if let controller = landscapeVC{
            controller.willMove(toParentViewController: nil)
            
            coordinator.animate(alongsideTransition: { (_) in
                if self.presentedViewController != nil{
                    self.dismiss(animated: true, completion: nil)
                }
                controller.view.alpha = 0
            }, completion: { (_) in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeVC = nil
            })
        }
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        perfomSearch()
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
    
    func showNetWorkError(){
        let alert = UIAlertController(title: "Opps...", message: "Houve um erro para acessar a loja da Itunes. Por favor tente novamente.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert,animated: true, completion: nil)
    }
    
    func perfomSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex){
            search.performSearch(for: searchBar.text!, category: category,completion: { (success) in
                if !success{
                    self.showNetWorkError()
                }
                self.tableview.reloadData()
            })
            
            tableview.reloadData()
            searchBar.resignFirstResponder()
            self.landscapeVC?.searchResultsReceived()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "ShowDetail"{
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
            }
         }
    }
}


extension SearchViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
            case .notSeachedYet:
                return 0
            case .loading:
                return 1
            case .noResults:
                return 1
            case .results(let list):
                return list.count
            }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch search.state {
        case .notSeachedYet:
            fatalError("Não tem nunca que chegar aqui")
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell,for: indexPath)
            let spinner = cell.viewWithTag(100) as!UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell,for: indexPath)
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell,for: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
            case .notSeachedYet, .loading, .noResults:
                return nil
            case .results:
                return indexPath
        }
    }
}

extension SearchViewController: UISearchBarDelegate{
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        perfomSearch()
    }
    
}

