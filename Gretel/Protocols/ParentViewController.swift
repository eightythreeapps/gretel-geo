//
//  ParentViewController.swift
//  Gretel
//
//  Created by Ben Reed on 17/11/2021.
//

import UIKit

protocol ParentViewController {
    
    var containerView:UIView! { get set }
    
    func add(viewController:UIViewController)
    func remove(viewController:UIViewController)
}

extension ParentViewController where Self:UIViewController {
        
    func add(viewController:UIViewController) {
        
        viewController.view.frame = self.containerView.bounds
        self.containerView.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            viewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        
        
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }
    
    func remove(viewController:UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}
