//
//  LocationPermissionViewController.swift
//  Gretel
//
//  Created by Ben Reed on 22/09/2021.
//

import Foundation
import UIKit


class LocationPermissionViewController: UIViewController, Storyboarded, PermissionGranting {
    
    var coordinator:AppPermissionsCoordinator?
    var locationDataProvider:LocationDataProvider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapHandler(_ sender: Any) {
        
       
    }
    
    func permissionGranted() {
        self.coordinator?.displayHealthPermissionsViewController()
    }
    
    func permissionDenied() {
        
    }
}
