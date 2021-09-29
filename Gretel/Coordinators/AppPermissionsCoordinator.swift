//
//  AppPermissionsCoordinator.swift
//  Gretel
//
//  Created by Ben Reed on 22/09/2021.
//

import Foundation
import UIKit

class AppPermissionsCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    var locationDataProvider:LocationDataProvider!
    
    weak var parentCoordinator:MainCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
        let vc = AppPermissionsViewController.instantiate()
        
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
        
    }
    
    func displayLocationPermissionsViewController() {
        
        let vc = LocationPermissionViewController.instantiate()
        vc.coordinator = self
        vc.locationDataProvider = self.locationDataProvider
        navigationController.pushViewController(vc, animated: true)
    
    }
    
    func displayHealthPermissionsViewController() {
        
        let vc = HealthPermissionsViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func wizardDidFinish() {
        self.parentCoordinator?.childDidFinish(child: self)
    }
    
}
