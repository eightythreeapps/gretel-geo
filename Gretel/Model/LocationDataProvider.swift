//
//  LocationDataProvider.swift
//  Gretel
//
//  Created by Ben Reed on 22/09/2021.
//

import Foundation
import CoreLocation
import Combine

typealias PermissionGranted = (Bool) -> Void

class LocationDataProvider:NSObject {
    
    private var locationManager:CLLocationManager
    private var locationPermissionGranted:PermissionGranted?
    
    public var locationPublisher:PassthroughSubject<CLLocation, Error>
    public var headingPublisher:PassthroughSubject<CLHeading, Error>
    public var permissionPublisher:PassthroughSubject<Bool, Never>
    
    @Published var hasLocatedUser = false
    
    required init(locationManager:CLLocationManager, locationPublisher:PassthroughSubject<CLLocation,Error>, permissionPublisher:PassthroughSubject<Bool, Never>, headingPublisher:PassthroughSubject<CLHeading, Error>) {
        
        self.locationManager = locationManager
        self.locationPublisher = locationPublisher
        self.headingPublisher = headingPublisher
        self.permissionPublisher = permissionPublisher
        
        super.init()
        self.configureLocationManager()
    }
    
    public func startTrackingLocation() {
        self.locationManager.startUpdatingHeading()
        self.locationManager.startUpdatingLocation()
    }
    
    public func stopTrackingLocation() {
        self.locationManager.stopUpdatingHeading()
        self.locationManager.stopUpdatingLocation()
    }
    
    public func requestAccessToUsersLocation() {
        
        let currentStatus = self.locationManager.authorizationStatus
        
        switch currentStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            self.permissionPublisher.send(true)
        case .denied, .restricted:
            self.permissionPublisher.send(false)
            break
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            break
        @unknown default:
            fatalError()
        }
        
    }
    
}

private extension LocationDataProvider {
    
    func configureLocationManager() {
        self.locationManager.delegate = self
    }
    
}

extension LocationDataProvider: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            self.permissionPublisher.send(true)
        default:
            self.permissionPublisher.send(false)
        }
        
        print("Location manager status changed: \(manager.authorizationStatus.rawValue)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            self.locationPublisher.send(location)
            
            if self.hasLocatedUser == false {
                self.hasLocatedUser = true
            }
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationPublisher.send(completion: .failure(error))
        self.hasLocatedUser = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.headingPublisher.send(newHeading)
    }
    
}
