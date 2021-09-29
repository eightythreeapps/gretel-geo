//
//  HealthPermissionsViewController.swift
//  Gretel
//
//  Created by Ben Reed on 22/09/2021.
//

import UIKit

class HealthPermissionsViewController: UIViewController, Storyboarded, PermissionGranting {
    
    var coordinator:AppPermissionsCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapHandler(_ sender: Any) {
        
    }
    
    func permissionGranted() {
        self.coordinator?.wizardDidFinish()
    }
    
    func permissionDenied() {
        
    }
    
}
