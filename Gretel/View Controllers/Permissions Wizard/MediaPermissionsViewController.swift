//
//  MediaPermissionsViewController.swift
//  Gretel
//
//  Created by Ben Reed on 19/11/2021.
//

import UIKit
import Photos

class MediaPermissionViewModel {
    
    var permissionsDataProvider:PermissionsDataProvider!
    
    func requestAccessToUsersPhotos(completion:@escaping (Bool) -> Void) {
    
        self.requestAccessToUsersPhotos(completion: completion)
        
    }
    
}

class MediaPermissionsViewController: UIViewController, Storyboarded, PermissionGranting {
    
    var coordinator:AppPermissionsCoordinator!
    var viewModel:MediaPermissionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func permissionGranted() {
        
    }
    
    func tapHandler(_ sender: Any) {
        
        self.viewModel.requestAccessToUsersPhotos { granted in
            self.permissionGranted()
        }
        
    }
    

}
