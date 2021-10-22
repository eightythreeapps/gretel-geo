//
//  LocationManager.swift
//  Gretel
//
//  Created by Ben Reed on 19/10/2021.
//

import Foundation
import CoreLocation

protocol LocationManager {
    
    var delegate: CLLocationManagerDelegate? {get set}
    var desiredAccuracy: CLLocationAccuracy {get set}
    var activityType: CLActivityType {get set}
    var allowsBackgroundLocationUpdates:Bool {get set}
    
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func startUpdatingHeading()
    func stopUpdatingHeading()
    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()
    
    func getAuthorizationStatus() -> CLAuthorizationStatus
}

extension CLLocationManager: LocationManager {
    
    func getAuthorizationStatus() -> CLAuthorizationStatus {
        return self.authorizationStatus
    }
    
}


