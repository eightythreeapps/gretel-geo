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
    
    override func viewDidLoad() {
        
        let trackDashboardViewModel = TrackDashboardViewModel(dashboardItems: self.viewModel.dashboardItems())
        
        self.trackDashboardViewContoller = TrackDashboardViewController.instantiate()
        self.trackDashboardViewContoller.viewModel = trackDashboardViewModel
     
        self.addBottomSheetViewController(viewController: self.trackDashboardViewContoller)
        
    }
    
}
