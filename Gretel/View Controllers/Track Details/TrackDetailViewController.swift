//
//  TrackDetailViewController.swift
//  Gretel
//
//  Created by Ben Reed on 14/11/2021.
//

import UIKit
import MapKit

class TrackDetailViewController: UIViewController, Storyboarded, BottomSheetHost {
    
    @IBOutlet var mapView:MKMapView!
    
    var viewModel:TrackDetailViewModel!
    var trackDashboardViewContoller:TrackDashboardViewController!
    var coordinator:MainCoordinator!
    
    override func viewDidLoad() {
        
        let dashboardController = self.coordinator.displayTrackDashboard(dashboardItems: self.viewModel.dashboardItems())
        self.addBottomSheetViewController(viewController: dashboardController)
        
    }
    
}
