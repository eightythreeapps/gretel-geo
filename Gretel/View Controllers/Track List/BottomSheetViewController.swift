//
//  BottomSheetViewController.swift
//  Gretel
//
//  Created by Ben Reed on 15/10/2021.
//

import UIKit

class BottomSheetViewController: UIViewController, Storyboarded, BottomSheet {
    
    var panGestureRecognizer: UIPanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture(recognizer:)))
        self.view.addGestureRecognizer(self.panGestureRecognizer!)
        self.view.backgroundColor = .clear
        
    }
    
    @objc func panGesture(recognizer: UIPanGestureRecognizer) {
        self.panHandler(recognizer: recognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.displayBottomSheetClosed()
    }
    
}
