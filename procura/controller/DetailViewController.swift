//
//  DetailViewController.swift
//  procura
//
//  Created by Bruno Corrêa on 16/01/2018.
//  Copyright © 2018 Bruno Lemgruber. All rights reserved.
//

import UIKit
import CoreImage

class DetailViewController: UIViewController {
    
    enum AnimationStyle{
        case slide
        case fade
    }
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var downloadTask: URLSessionDownloadTask?
    var dismissStyle = AnimationStyle.fade
    var isPopUp = false
    
    var searchResult: SearchResult!{
        didSet{
            if isViewLoaded{
                updateUI()
                popupView.isHidden = false
            }
        }
    }
    
    deinit {
        downloadTask?.cancel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isPopUp{
            view.backgroundColor = UIColor.clear

            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
        
        }else{
           view.backgroundColor = UIColor.white
           popupView.isHidden = true
           if let displayName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String{
                title = displayName
            }
        }
        
        if searchResult != nil {
            updateUI()
        }
    }
    
    @IBAction func close(){
        dismissStyle = .slide
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInStore(){
        if let url = URL(string: searchResult.storeURL){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func updateUI() {
        nameLabel.text = searchResult.name
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "Localized kind: Unknown")
        } else {
            artistNameLabel.text = searchResult.artistName
        }
        kindLabel.text = searchResult.type
        genreLabel.text = searchResult.genre
        
        // Formatar preço
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        let priceText: String
        if searchResult.price == 0 {
            priceText = NSLocalizedString("Free", comment: "Localized kind: Free")
        } else if let text = formatter.string(from: searchResult.price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }
        priceButton.setTitle(priceText, for: .normal)
        
        if let largeURL = URL(string: searchResult.imageLarge){
            downloadTask = artworkImageView.loadImage(url: largeURL, thumbnail: false)
        }
    }
    
}

extension DetailViewController: UIViewControllerTransitioningDelegate{
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented:UIViewController, presenting: UIViewController,source: UIViewController) ->
        UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle {
        case .fade:
            return FadeOutAnimationController()
        case .slide:
             return SlideOutAnimationController()
        }
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
