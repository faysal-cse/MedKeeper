//
//  AlarmsViewController.swift
//  MedKeeper
//
//  Created by Jonathan Robins on 10/4/15.
//  Copyright © 2015 Round Robin Apps. All rights reserved.
//

import UIKit
import CoreData

class AlarmsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MedicineHeaderCustomCellDelegate {
    

    @IBOutlet var alarmsTableView: UITableView!
    var medicineArray: NSArray = [NSManagedObject]() as NSArray
    var sectionBooleanArray:[Bool] = []
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(AlarmsViewController.addButtonPressed))
        navigationItem.rightBarButtonItem = addButton
        
        alarmsTableView.delegate = self
        alarmsTableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //if first time using app, demand name for patient profile
        let defaults = UserDefaults.standard
        if (defaults.integer(forKey: "FirstTimeLaunchingApp") != 1){
            //initial alertView
            var tField: UITextField!
            func configurationTextField(textField: UITextField!)
            {
                textField.returnKeyType = UIReturnKeyType.done
                tField = textField
                tField.delegate = self
            }
            let alert = UIAlertController(title: "Please Enter A Name For Your Patient Profile", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField(configurationHandler: configurationTextField)
            //this action is necessary for some reason or else keyboard doesn't dismiss correctly
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler:nil))
            self.present(alert, animated: true, completion: {
                print("First time alert view appeared!")
            })
        }
        else{
            navigationItem.title = (defaults.value(forKey: "CurrentUser") as! String) + "'s Medicines"
            defaults.synchronize()
            //user has already launched app before and made an initial profile
        }
        alarmsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if (defaults.integer(forKey: "FirstTimeLaunchingApp") == 1){
            //get current user and set the medicine array = to their medicines properties
            let currentUser:String = defaults.value(forKey: "CurrentUser") as! String
            let predicate = NSPredicate(format: "name == %@", currentUser)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PatientProfile")
            fetchRequest.predicate = predicate
            var fetchedCurrentUser:PatientProfile!
            do {
                let fetchedProfiles = try managedObjectContext.fetch(fetchRequest) as! [PatientProfile]
                fetchedCurrentUser = fetchedProfiles.first
                medicineArray = (fetchedCurrentUser.medicines.allObjects) as! [NSManagedObject] as NSArray
                medicineArray = medicineArray.sorted(by: { ($0 as AnyObject).name.lowercased() < ($1 as AnyObject).name.lowercased() }) as NSArray
                sectionBooleanArray = [Bool](repeating: false, count: medicineArray.count)
            } catch {
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(!((textField.text?.isEmpty)!)){
            saveInitialPatientProfile(name: textField.text! as NSString)
            return true
        }
        else{
            return false
        }
    }
    
    @objc func addButtonPressed(){
        performSegue(withIdentifier: "addMedicineSegue", sender: self)
    }
    
    func saveInitialPatientProfile(name : NSString){
        //save initial patient profile if user's first time using app, set as CurrentUser
        let defaults = UserDefaults.standard
        defaults.set(1, forKey: "FirstTimeLaunchingApp")
        defaults.setValue(name, forKey: "CurrentUser")
        navigationItem.title = (name as String) + "'s Medicines"
        defaults.synchronize()
        
        let managedContext = AppDelegate().managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "PatientProfile", in: managedContext)
        let person =  NSManagedObject(entity: entity!, insertInto: managedContext)
        person.setValue(name, forKey: "name")
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return medicineArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let medicine : Medicine = medicineArray[section] as! Medicine
        let alarms : NSSet = medicine.alarms
        
        if(sectionBooleanArray[section] == true){
            if(alarms.count > 0){
                return alarms.count
            }
            else{
                return 1
            }
        }
        else{
            return 0
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 37
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: AlarmsCustomCell! = tableView.dequeueReusableCell(withIdentifier: "alarmcustomcell") as? AlarmsCustomCell
        if(cell == nil) {
            tableView.register(UINib(nibName: "AlarmsCustomCell", bundle: nil), forCellReuseIdentifier: "alarmcustomcell")
            cell = tableView.dequeueReusableCell(withIdentifier: "alarmcustomcell") as? AlarmsCustomCell
        }
        //get medicine at indexPath and assign its alarm's properties to alarm cell
        let medicine : Medicine = medicineArray[indexPath.section] as! Medicine
        let alarms : NSArray = medicine.alarms.allObjects as NSArray
        if(alarms.count > 0){
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.none//DateFormatter.StyleDateFormatter.Style.NoStyle
            dateFormatter.timeStyle = DateFormatter.Style.short
            let alarm : Alarm = alarms[indexPath.row] as! Alarm
            cell.alarmTime.text = String(dateFormatter.string(from: alarm.time! as Date))
            cell.weekdays.text = alarm.weekdays
            cell.textLabel?.backgroundColor = UIColor.clear
        }
        else{
            var cell: NoAlarmsCustomCell! = tableView.dequeueReusableCell(withIdentifier: "noalarmscustomcell") as? NoAlarmsCustomCell
            if(cell == nil) {
                tableView.register(UINib(nibName: "NoAlarmsCustomCell", bundle: nil), forCellReuseIdentifier: "noalarmscustomcell")
                cell = tableView.dequeueReusableCell(withIdentifier: "noalarmscustomcell") as? NoAlarmsCustomCell
            }
            return cell
            //cell.imageView.image = imagewithnameblahblah
        }
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell: MedicineHeaderCustomCell! = tableView.dequeueReusableCell(withIdentifier: "headercustomcell") as? MedicineHeaderCustomCell
        if(cell == nil) {
            tableView.register(UINib(nibName: "MedicineHeaderCustomCell", bundle: nil), forCellReuseIdentifier: "headercustomcell")
            cell = tableView.dequeueReusableCell(withIdentifier: "headercustomcell") as? MedicineHeaderCustomCell
        }
        //assign medicine data object at index to medicine section cell
        let medicine = medicineArray[section] as? NSDictionary
        cell.medicineNameLabel.text = medicine?.value(forKey: "name") as? String//(medicine as AnyObject).value("name") as? String
        cell.dosageLabel.text = medicine?.value(forKey: "dosage") as? String//(medicine as AnyObject).value("dosage") as? String
        cell.medicineType = (medicine as AnyObject).type
        cell.section = section
        if((medicine as AnyObject).type == "Liquid"){
            cell.medicineImage.image = UIImage(named: "liquidIcon.png")
        }
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: alarmsTableView.frame.size.width, height: 50))
        view.backgroundColor = UIColor.darkGray
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func didSelectUserHeaderTableViewCell(Selected: Bool, UserHeader: MedicineHeaderCustomCell) {
        //save header's medicine name as current medicine
        let defaults = UserDefaults.standard
        defaults.setValue(UserHeader.medicineNameLabel.text, forKey: "CurrentMedicine")
        //performSegueWithIdentifier("segueToMedicineDetail", sender: self)
        
        sectionBooleanArray[UserHeader.section!] = !sectionBooleanArray[UserHeader.section!]
        if(sectionBooleanArray[UserHeader.section!] == true){
            UserHeader.arrowLabel.titleLabel!.text = "V"
        }
        else{
            UserHeader.arrowLabel.titleLabel!.text = ">"
        }
        //let indexPath: NSIndexSet = NSIndexSet.init(index: UserHeader.section!)
        //self.alarmsTableView.reloadSections(indexPath, withRowAnimation: .Automatic)
        alarmsTableView.reloadData()
    }

}

