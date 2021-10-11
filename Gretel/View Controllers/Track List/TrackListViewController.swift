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
    public var trackDataProvider:TrackDataProvider!
    public var trackRecorder:TrackRecorder!
    
    private var fetchedResultsController:NSFetchedResultsController<Track>!
    
    @IBOutlet var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Track list"
        
        let startTrackButton = UIBarButtonItem(systemItem: .add)
        startTrackButton.target = self
        startTrackButton.action = #selector(startButtonHandler(sender:))
        
        self.navigationItem.rightBarButtonItems = [startTrackButton]
        
        self.fetchedResultsController = self.trackDataProvider.trackListResultsController()
        self.fetchedResultsController.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        
    }
    
}

extension TrackListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let track = self.fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = track.name
        cell.detailTextLabel?.text = "\(String(describing: track.dateStarted))"
        
        if let activeTrack = self.trackRecorder.getCurrentTrack() {
            if track.id == activeTrack.id {
                cell.backgroundColor = .green
            }else{
                cell.backgroundColor = .white
            }
        }else{
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = self.fetchedResultsController.object(at: indexPath)
        self.coordinator.displayTrackDetail(track: track)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sections = self.fetchedResultsController.sections else {
            return ""
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.name
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
            
            let track = self.fetchedResultsController.object(at: indexPath)
            self.trackDataProvider.deleteTrack(track: track)
            
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
            guard let newIndexPath = newIndexPath else { return }
            self.tableView.deleteRows(at: [newIndexPath], with: .automatic)
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

private extension TrackListViewController {
    
    @objc func startButtonHandler(sender:UIBarButtonItem) {
        self.coordinator.displayTrackDetail(track: nil)
    }
    
}
