//
//  DimmingPresentationController.swift
//  procura
//
//  Created by Bruno Corrêa on 16/01/2018.
//  Copyright © 2018 Bruno Lemgruber. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    //Colocar o gradiente na view do detalhe
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
     //Quando a VC do detalhe começa a aparecer. Deixa o gradiente com alpha 1
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0)
        
        dimmingView.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator{
            coordinator.animate(alongsideTransition: { (_) in
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    //Quando a VC do detalhe começa a sair. Deixa o gradiente com alpha 0
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator{
            coordinator.animate(alongsideTransition: { (_) in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
}
