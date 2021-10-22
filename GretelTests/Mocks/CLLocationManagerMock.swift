//
//  CLLocationManagerMock.swift
//  GretelTests
//
//  Created by Ben Reed on 19/10/2021.
//

import Foundation
import CoreLocation

class CLLocationManagerMock: LocationManager {
    
    var delegate: CLLocationManagerDelegate?
    var desiredAccuracy: CLLocationAccuracy = 100.0
    var activityType: CLActivityType = .fitness
    var allowsBackgroundLocationUpdates: Bool = true
    
    func startUpdatingLocation() {
        
    }
    
    func stopUpdatingLocation() {
        
    }
    
    func startUpdatingHeading() {
        
    }
    
    func stopUpdatingHeading() {
        
    }
    
    func requestWhenInUseAuthorization() {
        
    }
    
    func requestAlwaysAuthorization() {
        
    }
    
    func getAuthorizationStatus() -> CLAuthorizationStatus {
        return .authorizedAlways
    }
    
    
}
