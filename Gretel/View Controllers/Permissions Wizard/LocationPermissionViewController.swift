//
//  LocationPermissionViewController.swift
//  Gretel
//
//  Created by Ben Reed on 22/09/2021.
//

import Foundation
import UIKit
import Combine

class LocationPermissionViewModel:ObservableObject {
    
    var locationDataProvider:LocationDataProvider!
    var permissionsDataProvider:PermissionsDataProvider!
        
    required init(locationDataProvider:LocationDataProvider, permissionsDataProvider:PermissionsDataProvider) {
        self.locationDataProvider = locationDataProvider
        self.permissionsDataProvider = permissionsDataProvider
    }
    
    func requestAccessToUserPermission() {
        self.permissionsDataProvider.requestAccessToUsersLocation()
    }

}


class LocationPermissionViewController: UIViewController, Storyboarded, PermissionGranting {
    
    var permissionDataProvider: PermissionsDataProvider!
    var coordinator:AppPermissionsCoordinator!
    var viewModel:LocationPermissionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tapHandler(_ sender: Any) {
        self.viewModel.requestAccessToUserPermission()
    }
    
    func permissionGranted() {
        
    }
    
    
}
