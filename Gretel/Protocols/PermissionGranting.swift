//
//  PermissionGranting.swift
//  Gretel
//
//  Created by Ben Reed on 22/09/2021.
//

import Foundation
import UIKit

protocol PermissionGranting {
    
    func permissionGranted()
    func permissionDenied()
    
    func tapHandler(_ sender: Any)
}

extension PermissionGranting where Self:UIViewController {
    
    func permissionDenied() {
       
        print("Permission not granted")
        
    }
    
}
