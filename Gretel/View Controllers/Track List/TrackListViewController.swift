//
//  TrackListViewController.swift
//  Gretel
//
//  Created by Ben Reed on 24/09/2021.
//

import UIKit
import CoreData

class TrackListViewController: UIViewController, Storyboarded {
    
    //Dependencies
    public var coordinator:MainCoordinator!
    public var trackDataProvider:TrackDataProvider!
    
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
    
}

extension TrackListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
}

extension TrackListViewController {
    
    @objc func startButtonHandler(sender:UIBarButtonItem) {
        self.coordinator.displayTrackDetail(track: nil)
    }
    
}
