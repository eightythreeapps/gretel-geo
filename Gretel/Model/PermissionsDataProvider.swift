//
//  PermissionsDataProvider.swift
//  Gretel
//
//  Created by Ben Reed on 19/11/2021.
//

import Foundation
import Combine
import CoreLocation
import Photos

enum PermissionType {
    case location
    case photo
}

typealias PermissionTypes = [PermissionType]

class PermissionsDataProvider {
    
    private var grantedPermissions:PermissionTypes = PermissionTypes()
    private var locationManager:CLLocationManager!
    
    public var permissionPublisher:PassthroughSubject<Bool, Never>
    
    required init(permissionPublisher:PassthroughSubject<Bool, Never>, locationManager:CLLocationManager) {
        self.permissionPublisher = permissionPublisher
        self.locationManager = locationManager
    }
    
    func requestAccessToUsersLocation() {
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func requestAccessToUsersPhotos() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { authStatus in
            if authStatus == .authorized {
                self.grantedPermissions.append(.photo)
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            self.grantedPermissions.append(.location)
        default:
            print("Location permission not granted")
            //self.permissionPublisher.send(false)
        }
        
        print("Location manager status changed: \(manager.authorizationStatus.rawValue)")
    }
    
    
    
}
