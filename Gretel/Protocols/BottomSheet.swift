//
//  BottomSheet.swift
//  Gretel
//
//  Created by Ben Reed on 15/10/2021.
//

import UIKit


protocol BottomSheetHost {
    func addBottomSheetViewController(viewController:BottomSheetViewController)
}

extension BottomSheetHost where Self:UIViewController {
    
    func addBottomSheetViewController(viewController:BottomSheetViewController) {
       
        self.addChild(viewController)
        
        self.view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        let height = self.view.frame.height
        let width  = self.view.frame.width
        
        viewController.view.frame = CGRect(x: 0, y: -height, width: width, height: height)
        
    }
    
}

protocol BottomSheet {
    
    var panGestureRecognizer:UIPanGestureRecognizer? { get set }
    
    func displayBottomSheetClosed()
    func prepareBackgroundView()
    func panHandler(recognizer: UIPanGestureRecognizer)
}

extension BottomSheet where Self:UIViewController {

    func displayBottomSheetClosed() {
        
        let frame = self.view.frame
        let yComponent = CGFloat(400.0)
        self.view.frame = CGRect(x: 0, y: yComponent, width: frame.width, height: frame.height)
        
    }
    
    func prepareBackgroundView(){
        
        let blurEffect = UIBlurEffect(style: .light)
        let visualEffect = UIVisualEffectView(effect: blurEffect)
        let bluredView = UIVisualEffectView(effect: blurEffect)
        
        let handleView = UIView(frame: CGRect(x: 0, y: 0, width: 100.0, height: 5.0))
        handleView.translatesAutoresizingMaskIntoConstraints = false
        
        handleView.backgroundColor = .black
        handleView.alpha = 0.5
        handleView.layer.cornerRadius = 2.5
        
        bluredView.contentView.addSubview(visualEffect)
        bluredView.contentView.addSubview(handleView)
    
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds

        self.view.insertSubview(bluredView, at: 0)
        
        handleView.center = CGPoint(x: bluredView.frame.width / 2, y: 10)
        
    }
    
    func panHandler(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let y = self.view.frame.minY
        
        self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
}
