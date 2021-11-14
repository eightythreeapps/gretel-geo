//
//  TrackListViewController.swift
//  Gretel
//
//  Created by Ben Reed on 24/09/2021.
//

import UIKit
import CoreData
import Combine

class TrackListViewController: UIViewController, Storyboarded {
    
    //Dependencies
    public var coordinator:MainCoordinator!
    public var viewModel:TrackListViewModel!
    
    @IBOutlet var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Track list".localized
        
        let startTrackButton = UIBarButtonItem(systemItem: .add)
        startTrackButton.target = self
        startTrackButton.action = #selector(startButtonHandler(sender:))
        
        self.navigationItem.rightBarButtonItems = [startTrackButton]
        self.tableView.dataSource = self.viewModel
        self.tableView.delegate = self
        
        self.viewModel.fetchedResultsController.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.viewModel.fetchData()
    }
    
}

extension TrackListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = self.viewModel.track(forIndexPath: indexPath)
        self.coordinator.displayTrackDetail(track: track)
    }
    
}

private extension TrackListViewController {
    
    @objc func startButtonHandler(sender:UIBarButtonItem) {
        //self.coordinator.displayTrackDetail(track: nil)
    }
    
}

extension TrackListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.viewModel.deleteObject(at: indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            self.tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let newIndexPath = newIndexPath else { return }
            self.tableView.reloadRows(at: [newIndexPath], with: .none)
        case .move:
            self.tableView.reloadData()
        case .delete:
            guard let indexPath = indexPath else { return }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            fatalError()
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
                
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move, .update:
            self.tableView.reloadData()
        @unknown default:
            fatalError()
        }
    
    }
    
}
