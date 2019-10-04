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
    private var myTableView: UITableView!
    private var users: Array<Any>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateUserbase(completion: {
            print("purses count = \(self.users)")
            return self.users
        })
        configureViewComponents()
        
    }
    
    func setUsers(u: [String]) {
        self.users.append(u)
        print(self.users)
    }
    
    
    func populateUserbase(completion: () -> Array<Any>?){
                        var newNames: [String] = []
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {

                for document in querySnapshot!.documents {
                    
                    let documentData = document.data()
                    newNames.append(documentData["username"] as? String ?? "")
                    print("\(document.documentID) => \(document.data())")
                    self.setUsers(u: newNames)
                }


            }
            
        }
        
    }
    
    
    func configureViewComponents(){
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        configureTableView()
        
    }
    
    func configureTableView(){
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        //added
        myTableView.contentInset = UIEdgeInsets(top: 50, left: 0,  bottom: 0, right: 0)
        
        self.view.addSubview(myTableView)
    }
}
