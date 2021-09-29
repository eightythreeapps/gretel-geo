//
//  Storyboarded.swift
//  Gretel
//
//  Created by Ben Reed on 22/09/2021.
//

import Foundation
import UIKit

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self:UIViewController {
    
    static func instantiate() -> Self {
        
        let id = String(describing: self)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(identifier: id) as! Self
        
    }
    
}
