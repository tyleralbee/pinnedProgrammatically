//
//  PinViewController.swift
//  pinnedProgrammatically
//
//  Created by Tyler Albee on 8/23/19.
//  Copyright © 2019 Tyler Albee. All rights reserved.
//

import UIKit
import MapKit

class PinViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var myTableView: UITableView!
    private var mySearchBar: UISearchBar!
    
    //Search Bar Auto Complete Variables
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewComponents()
    }
    
    
    func configureViewComponents(){
        configureTableView()
        configureSearchBar()
    }
    
    func configureTableView(){
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height

        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
    }
    
    func configureSearchBar(){
        mySearchBar = UISearchBar()
        mySearchBar.searchBarStyle = UISearchBar.Style.prominent
        mySearchBar.placeholder = " Search... "
        mySearchBar.sizeToFit()
        mySearchBar.isTranslucent = false
        mySearchBar.delegate = self
        searchCompleter.delegate = self
        navigationItem.titleView = mySearchBar
        
        self.view.addSubview(mySearchBar)
    }
    
    //SELECTING A ROW OF THE TABLE
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let coordinate = response?.mapItems[0].placemark.coordinate
            print(String(describing: coordinate))
            
            //let homeController = HomeMapViewController()
            //homeController.addAnnotation(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
            self.navigationController?.popViewController(animated: true)
            
            db.collection("pins").addDocument(data: [
                "latitude" : coordinate!.latitude,
                "longitude" : coordinate!.longitude,
                ])
        }
        
        
    }
    
    //NUMBER OF ROWS IN TABLE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    //CELLS IN TABLE
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
}

extension PinViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

extension PinViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        myTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}
