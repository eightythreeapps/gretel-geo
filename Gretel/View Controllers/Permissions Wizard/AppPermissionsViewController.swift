//
//  ViewController.swift
//  Gretel
//
//  Created by Ben Reed on 22/09/2021.
//

import UIKit

class AppPermissionsViewController: UIViewController, Storyboarded {
    
    var coordinator:AppPermissionsCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startPermissionsWizard(_ sender: Any) {
        self.coordinator?.displayLocationPermissionsViewController()
    }
    
}

