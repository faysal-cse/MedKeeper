//
//  AlarmsViewController.swift
//  MedKeeper
//
//  Created by Jonathan Robins on 10/4/15.
//  Copyright © 2015 Round Robin Apps. All rights reserved.
//

import UIKit
import CoreData

class AlarmsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var alarmsTableView: UITableView!
    @IBOutlet var alarmsControllerTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action:"addButtonPressed")
        navigationItem.rightBarButtonItem = addButton
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let defaults = NSUserDefaults.standardUserDefaults()
       // var newTitleString = (defaults.objectForKey("CurrentUser") as? String)! + "'s " + "Alarms"
        //newTitleString.replaceRange(newTitleString.startIndex...newTitleString.startIndex, with: String(newTitleString[newTitleString.startIndex]).capitalizedString)
        //self.alarmsControllerTitle.text = newTitleString
        
        if (defaults.integerForKey("FirstTimeLaunchingApp") != 1){
            //initial alertView
            var tField: UITextField!
            func configurationTextField(textField: UITextField!)
            {
                textField.returnKeyType = UIReturnKeyType.Done
                tField = textField
                tField.delegate = self
            }
            let alert = UIAlertController(title: "Please Enter A Name For Your Patient Profile", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler(configurationTextField)
            //this action is necessary for some reason or else keyboard doesn't dismiss correctly
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler:nil))
            self.presentViewController(alert, animated: true, completion: {
                print("First time alert view appeared!")
            })
        }
        else{
            //user has already launched app before and made an initial profile
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField.text?.characters.count > 0){
            saveInitialPatientProfile(textField.text!)
            return true
        }
        else{
            return false
        }
    }
    
    func addButtonPressed(){
        performSegueWithIdentifier("addMedicineSegue", sender: self)
    }
    
    func saveInitialPatientProfile(name : NSString){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(1, forKey: "FirstTimeLaunchingApp")
        defaults.setValue(name, forKey: "CurrentUser")
        defaults.synchronize()
        
        let managedContext = AppDelegate().managedObjectContext
        let entity =  NSEntityDescription.entityForName("PatientProfile", inManagedObjectContext: managedContext)
        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        person.setValue(name, forKey: "name")
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}

