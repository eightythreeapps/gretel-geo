//
//  ViewControllerFactory.swift
//  Gretel
//
//  Created by Ben Reed on 17/11/2021.
//

import UIKit

class ViewControllerFactory {

    public static func trackViewController() -> TrackDashboardViewController {
        
        let trackRecorderViewController = TrackDashboardViewController.instantiate()
        return trackRecorderViewController
        
    }
    
}
