//
//  FriendViewController.swift
//  pinnedProgrammatically
//
//  Created by Tyler Albee on 9/9/19.
//  Copyright © 2019 Tyler Albee. All rights reserved.
//

import UIKit
import MapKit

class FriendViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewComponents()
    }
    
    
    func configureViewComponents(){
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
