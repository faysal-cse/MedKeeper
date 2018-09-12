//
//  AddNewProfileViewController.swift
//  MedKeeper
//
//  Created by Jonathan Robins on 11/15/15.
//  Copyright © 2015 Round Robin Apps. All rights reserved.
//

import UIKit
import CoreData

class AddNewProfileViewController: UIViewController {
    
    @IBOutlet var newProfileTextField: UITextField!
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()

        newProfileTextField.becomeFirstResponder()
        
        navigationItem.title = "Add a New Profile"
        
        let backButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(AddNewProfileViewController.cancelButtonPressed))
        navigationItem.leftBarButtonItem = backButton
        let nextButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(AddNewProfileViewController.doneButtonPressed))
        navigationItem.rightBarButtonItem = nextButton

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func cancelButtonPressed(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func doneButtonPressed(){
        //check that this profile name hasnt been registered before
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PatientProfile")
        var nameNotTaken:Bool = true
        do {
            let results =
                try managedObjectContext.fetch(fetchRequest)
            let profileArray:NSArray = results as! [NSManagedObject] as NSArray
            for profile in profileArray{
                let fetchedProfile = profile as! PatientProfile
                if(fetchedProfile.name == newProfileTextField.text){
                    let alert = UIAlertController(title: "Profile name already taken!", message: "Please enter a different profile name.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    nameNotTaken = false
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        if(nameNotTaken){
            //save patient profile
            let newPatientProfile = NSEntityDescription.insertNewObject(forEntityName: "PatientProfile", into: self.managedObjectContext) as! PatientProfile
            newPatientProfile.name = newProfileTextField.text
            do{
                try self.managedObjectContext.save()
                self.navigationController?.popToRootViewController(animated: true)
            } catch let error as NSError{
                print(error)
            }
            
            /*//set new profile array and reload table data
            let fetchRequest = NSFetchRequest(entityName: "PatientProfile")
            do {
                let results =
                try self.managedObjectContext.executeFetchRequest(fetchRequest)
                profileArray = results as! [NSManagedObject]
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            self.profilesTableView.reloadData()
            
            let indexPath = NSIndexPath(forRow: self.profileArray.count-1, inSection: 0)
            self.profilesTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)*/
        }

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
