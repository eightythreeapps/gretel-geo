//
//  AppPermissionsCoordinator.swift
//  Gretel
//
//  Created by Ben Reed on 22/09/2021.
//

import Foundation
import UIKit

enum PermissionWizardStage {
    case location
    case photos
}

class AppPermissionsCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var locationDataProvider:LocationDataProvider!
    var permissionDataProvider:PermissionsDataProvider!
        
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
        
        let vm = LocationPermissionViewModel(locationDataProvider: self.locationDataProvider,
                                             permissionsDataProvider: self.permissionDataProvider)
        vc.viewModel = vm
        navigationController.pushViewController(vc, animated: true)
    
    }
    
    func displayMediaPermissionsViewController() {
        
        let vc = MediaPermissionsViewController()
        let vm = MediaPermissionViewModel()
        vc.viewModel = vm
        
        navigationController.pushViewController(vc, animated: true)
        
    }
    
    func wizardDidFinish() {
        self.parentCoordinator?.childDidFinish(child: self)
    }
    
    func permissionDenied(permissionType:PermissionType) {
        print("User denied: \(permissionType)")
        self.parentCoordinator?.childDidFinish(child: self)
    }
    
}
