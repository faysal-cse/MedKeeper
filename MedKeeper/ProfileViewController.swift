//
//  FirstViewController.swift
//  MedKeeper
//
//  Created by Jonathan Robins on 10/4/15.
//  Copyright © 2015 Round Robin Apps. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet var profilesTableView: UITableView!
    var profileArray: NSArray = [NSManagedObject]() as NSArray
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(addProfileButtonPressed))
        navigationItem.rightBarButtonItem = addButton
        
        self.profilesTableView.delegate = self
        self.profilesTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PatientProfile")
        do {
            try managedObjectContext.fetch(fetchRequest)
            profileArray = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject] as NSArray
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        profilesTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return profileArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64;
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ProfileCustomCell! = tableView.dequeueReusableCell(withIdentifier: "profileCustomCell") as? ProfileCustomCell
            if(cell == nil) {
                tableView.register(UINib(nibName: "ProfileCustomCell", bundle: nil), forCellReuseIdentifier: "profileCustomCell")
                cell = tableView.dequeueReusableCell(withIdentifier: "profileCustomCell") as? ProfileCustomCell
            }
            let patientProfile:PatientProfile = profileArray[indexPath.row] as! PatientProfile
            cell.nameLabel.text = patientProfile.name
        cell.textLabel?.backgroundColor = UIColor.clear
            return cell
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: NSIndexPath) {
        let patientProfile:PatientProfile = profileArray[indexPath.row] as! PatientProfile
        let defaults = UserDefaults.standard
        defaults.set(patientProfile.value(forKey: "name"), forKey: "CurrentUser")
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PatientProfile")
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            profileArray = results as! [NSManagedObject] as NSArray
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        profilesTableView.reloadData()

        //self.performSegueWithIdentifier("profileCellToDetailedProfileVC", sender: self)
    }

    @objc func addProfileButtonPressed(sender: AnyObject) {
        self.performSegue(withIdentifier: "addNewProfileSegue", sender: self)
    }

}

