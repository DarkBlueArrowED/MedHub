//
//  MedicalSearchViewController.swift
//  Medical Hub
//
//  Created by Walter Bassage on 27/03/2018.
//  Copyright © 2018 Walter Bassage. All rights reserved.
//

import UIKit

class MedicalSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // UI outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var medInfoTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var medInfoFilter = MedInfoFilter(medInfoCollection: MedInfoCollection())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        medInfoFilter.searchString = ""
        medInfoTextView.text = medInfoFilter.filteredMedData.first
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        if let searchString = searchBar.text {
            medInfoFilter.searchString = searchString
            tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medInfoFilter.filteredMedData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let medData = medInfoFilter.filteredMedData[indexPath.row]
        
        cell.textLabel?.text = medData
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = medInfoFilter.filteredMedData[indexPath.row]
        medInfoTextView.text = entry
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // For making screen landscape and not portrat
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
        }
        
    }
    
}

