//
//  MainCoordinator.swift
//  Gretel
//
//  Created by Ben Reed on 22/09/2021.
//

import Foundation
import UIKit
import Combine

class MainCoordinator:NSObject, Coordinator, UINavigationControllerDelegate {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    var locationDataProvider:LocationDataProvider!
    var trackDataProvider:TrackDataProvider!
    var trackRecorder:TrackRecorder!
    
    private var cancellables:[AnyCancellable] = []
        
    init(navigationController:UINavigationController, locationDataProvider:LocationDataProvider, trackDataProvider:TrackDataProvider, trackRecorder:TrackRecorder) {
        
        self.navigationController = navigationController
        self.trackRecorder = trackRecorder
        self.locationDataProvider = locationDataProvider
        self.trackDataProvider = trackDataProvider
        
    }
    
    func start() {
        
//        self.locationDataProvider.permissionPublisher.sink { granted in
//            if granted {
//                self.navigationController.delegate = self
//                self.displayTrackRecorderViewController()
//            }else{
//                self.displayAppPermissionsWizard()
//            }
//        }.store(in: &cancellables)
//        
    }
    
    func childDidFinish(child:Coordinator?) {
        
        for (index, coordinator) in self.childCoordinators.enumerated() {
            if coordinator === child {
                self.childCoordinators.remove(at: index)
                break
            }
        }
        
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        //Do we have a from view controller?
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        //Yes? Ok is it contained in our viewControllers array
        if navigationController.viewControllers.contains(fromViewController) {
            return
        }
        
    }
    
}

extension MainCoordinator {
    
    func displayTrackList() {
        
        let trackListViewModel = TrackListViewModel(trackDataProvider: self.trackDataProvider,
                                                    trackRecorder: self.trackRecorder,
                                                    fetchedResultsController: self.trackDataProvider.trackListResultsController())
        
        let vc = TrackListViewController.instantiate()
        vc.coordinator = self
        vc.viewModel = trackListViewModel
        self.navigationController.pushViewController(vc, animated: false)
    }
    
    func displayTrackDetail(track:Track) {
        
        let viewModel = TrackDetailViewModel(track: track)
        let vc = TrackDetailViewController.instantiate()
        vc.viewModel = viewModel
        vc.coordinator = self
        
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func displayAppPermissionsWizard() {
        
        let child = AppPermissionsCoordinator(navigationController: self.navigationController)
        child.parentCoordinator = self
        child.locationDataProvider = self.locationDataProvider
        //child.permissionDataProvider = PermissionsDataProvider(permissionPublisher: <#T##PassthroughSubject<Bool, Never>#>, locationManager: )
        self.childCoordinators.append(child)
        child.start()
        
    }
    
    //Entry point
    func displayTrackRecorderViewController() {
        
        let vc = TrackRecorderViewController.instantiate()
        let vm = TrackRecorderViewModel(locationDataProvider: self.locationDataProvider,
                                        trackDataProvider: self.trackDataProvider,
                                        trackRecorder: self.trackRecorder)
        vc.viewModel = vm
        self.navigationController.pushViewController(vc, animated: false)
    }

}

extension MainCoordinator {
    
    func displayTrackDashboard(dashboardItems:TrackDetailDashboardItems) -> TrackDashboardViewController {
        
        let trackDashboardViewModel = TrackDashboardViewModel(dashboardItems: dashboardItems)
        let trackDashboardViewController = TrackDashboardViewController.instantiate()
        trackDashboardViewController.viewModel = trackDashboardViewModel
     
        return trackDashboardViewController
        
    }
    
    func embedTrackDashboard(dashboardItems:TrackDetailDashboardItems, containerView:UIView) -> TrackDashboardViewController {
        
        let trackDashboardViewModel = TrackDashboardViewModel(dashboardItems: dashboardItems)
        let trackDashboardViewController = TrackDashboardViewController.instantiate()
        trackDashboardViewController.viewModel = trackDashboardViewModel
     
        return trackDashboardViewController
        
    }

}

