//
//  HomeMapViewController.swift
//  pinnedProgrammatically
//
//  Created by Tyler Albee on 8/22/19.
//  Copyright © 2019 Tyler Albee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseUI


class HomeMapViewController: UIViewController, CLLocationManagerDelegate {
    
    private var homeMap: MKMapView!
    private var locationManager: CLLocationManager!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUserAndConfigureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureLocationManager()
        configureViewComponents()
        configurePinsToShow()
    }
    
    func configurePinsToShow(){
        db.collection("pins").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let myLat = document.data()["latitude"]
                    let myLong = document.data()["longitude"]
                    
                    let pinner2 = MKPointAnnotation()
                    pinner2.coordinate.latitude = myLat as! CLLocationDegrees
                    pinner2.coordinate.longitude = myLong as! CLLocationDegrees
                                        
                    self.homeMap.addAnnotation(pinner2)
                    
                }
            }
        }
    }
    
    func configureViewComponents() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        configureMapView()
        configureButtons()
    }
    
    func configureMapView() {
        //create homeMap
        homeMap = MKMapView()
        //bounds for map width and height will be screen width and height
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        //what are x and y? left and top margins, respectively, but what does changing their values do?
        homeMap.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        
        //maptype of homemap: standard, mutedStandard, satellite, satelliteFlyover, hybrid, hybridFlyover
        //probably want standard or satellite
        
        //default values:
        //homeMap.mapType = MKMapType.standard
        //homeMap.isZoomEnabled = true
        //homeMap.isScrollEnabled = true
        
        //we want the user to be able to see his/her location
        homeMap.showsUserLocation = true
        
        view.addSubview(homeMap)
    }
    
    func configureButtons(){
        
        //configure pin button
        configurePinButton()
        configureSignOutButton()

    }
    
    func configurePinButton(){
        let button = UIButton(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        button.backgroundColor = .red
        button.setTitle("Pin", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        view.addSubview(button)
        
        button.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 40, paddingRight: 0, width: 50, height: 50)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func configureSignOutButton(){
        let button = UIButton(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        button.backgroundColor = .red
        button.setTitle("Sign Out", for: .normal)
        button.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)
        
        view.addSubview(button)
        
        button.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func addAnnotation(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let anno = MKPointAnnotation()
        anno.coordinate.latitude = latitude
        anno.coordinate.longitude = longitude
        homeMap.addAnnotation(anno)
    }

    
    //https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
    func configureLocationManager(){
        locationManager = CLLocationManager()
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //set the delegate of the locationManager to the HomeMapViewController
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.homeMap.setRegion(region, animated: true)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
        let pinViewController = PinViewController()

        self.navigationController?.pushViewController(pinViewController, animated: true)
        
    }
    
    func authenticateUserAndConfigureView() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let navController = UINavigationController(rootViewController: LoginViewController())
                navController.navigationBar.barStyle = .black
                self.present(navController, animated: true, completion: nil)
            }
        } else {
            configureLocationManager()
            configureViewComponents()
            configurePinsToShow()
        }
    }
    
    @objc func handleSignOut() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            self.signOut()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            let navController = UINavigationController(rootViewController: LoginViewController())
            navController.navigationBar.barStyle = .black
            self.present(navController, animated: true, completion: nil)
        } catch let error {
            print("Failed to sign out with error..", error)
        }
    }

}
