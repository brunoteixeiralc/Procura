//
//  LandscapeViewController.swift
//  procura
//
//  Created by Bruno Lemgruber on 22/01/2018.
//  Copyright © 2018 Bruno Lemgruber. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var searchResults = [SearchResult]()
    var search: Search!
    private var firstTime = true
    private var downloads = [URLSessionDownloadTask]()
    
    deinit {
        for task in downloads{
            task.cancel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Estamos tirando o AutoLayout somente dessa VC.
        //Caso tire no Interface Builder , irá desativar para todas as VCs
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        //scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        scrollView.contentSize = CGSize(width: 1000, height: 1000)
        
        pageControl.numberOfPages = 0
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        pageControl.frame = CGRect(x: 0, y: view.frame.size.height - pageControl.frame.size.height, width: view.frame.size.width, height: pageControl.frame.size.height)
        
        if firstTime{
            firstTime = false
            switch search.state{
                case .notSeachedYet : break
                case .loading: showSpinner()
                case .noResults : showNothingFoundLabel()
                case .results(let list):
                    titleButtons(list)
            }
        }
    }
    
    //@objc quando é chamado via #selector
    @objc func buttonPressed(_ sender: UIButton){
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
        }, completion: nil)
    }
    
    func searchResultsReceived(){
        hideSpinner()
        
        switch search.state {
        case .notSeachedYet, .loading :
            break
        case .noResults: showNothingFoundLabel()
        case .results(let list):
            titleButtons(list)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail"{
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let searchResult = list[(sender as! UIButton).tag - 2000]
                detailViewController.searchResult = searchResult
            }
        }
    }
    
    private func downloadImage(for searchResult:SearchResult, andPlaceOn button: UIButton){
        if let url = URL(string: searchResult.imageSmall){
            let task = URLSession.shared.downloadTask(with: url) {
                [weak button] url, response, error in
                
                if error == nil, let url = url,
                    let data = try? Data(contentsOf:url),
                    let image = UIImage(data:data){
                    DispatchQueue.main.async {
                        if let button = button{
                            button.setImage(image, for: .normal)
                        }
                    }
                }
            }
            task.resume()
            downloads.append(task)
        }
    }
    
    private func showNothingFoundLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Nenhum Resultado"
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.clear
        
        label.sizeToFit()
        
        var rect = label.frame
        //If you divide a number such as 11 by 2 you get 5.5. The ceil() function rounds up 5.5 to make 6, and then you multiply by 2 to get a final value of 12. This formula always gives you the next even number if the original is odd
        rect.size.width = ceil(rect.size.width/2) * 2
        rect.size.height = ceil(rect.size.height/2) * 2
        label.frame = rect
        
        label.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
        view.addSubview(label)
    }
    
    private func showSpinner(){
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.center = CGPoint(x: scrollView.bounds.midX + 0.5, y: scrollView.bounds.midY + 0.5)
        spinner.tag = 1000
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    private func hideSpinner(){
        view.viewWithTag(100)?.removeFromSuperview()
    }
    
    private func titleButtons(_ searchResults:[SearchResult]){
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        
        let viewWidth = scrollView.bounds.size.width
        
        //Tamanhos da largura da tela
        //480 points, 3.5-inch device
        //568 points, 4-inch device
        //667 points, 4.7-inch device
        //736 points, 5.5-inch device
        switch viewWidth {
        case 568:
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
        case 667:
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
        case 736:
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
        default:
            break
        }
        
        // Button size
        let buttonWidth: CGFloat = 74
        let buttonHeight: CGFloat = 74
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        
        // Add the buttons
        var row = 0
        var column = 0
        var x = marginX
        for (index, result) in searchResults.enumerated() {
            let button = UIButton(type: .custom)
            button.tag = 2000 + index
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            button.frame = CGRect(x: x + paddingHorz, y: marginY + CGFloat(row)*itemHeight + paddingVert, width: buttonWidth, height: buttonHeight)
            downloadImage(for: result, andPlaceOn: button)
            
            scrollView.addSubview(button)

            row += 1
            if row == rowsPerPage {
                row = 0; x += itemWidth; column += 1
                if column == columnsPerPage {
                    column = 0; x += marginX * 2
                }
            }
        }
        
        // Set scroll view content size
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth,height: scrollView.bounds.size.height)
        print("Number of pages: \(numPages)")
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }
}

extension LandscapeViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        pageControl.currentPage = page
    }
    
}
