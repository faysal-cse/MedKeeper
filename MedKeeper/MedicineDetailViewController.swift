//
//  MedicineDetailViewController.swift
//  MedKeeper
//
//  Created by Jonathan Robins on 11/6/15.
//  Copyright © 2015 Round Robin Apps. All rights reserved.
//

import UIKit
import CoreData

class MedicineDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    @IBOutlet var medicineDetailTableView: UITableView!
    @IBOutlet var medicineImage: UIImageView!
    var fetchedCurrentMedicine : Medicine!
    var fetchedAlarms: NSArray!
    var medicineName : String = ""
    var medicineType : String = ""
    var dosageAmount : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        medicineDetailTableView.delegate = self
        medicineDetailTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        let currentMedicine:String = defaults.value(forKey: "CurrentMedicine") as! String
        let currentUser:String = defaults.value(forKey: "CurrentUser") as! String
        let predicate = NSPredicate(format: "name == %@", currentUser)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PatientProfile")
        fetchRequest.predicate = predicate
        var fetchedCurrentUser:PatientProfile!
        do {
            let fetchedProfiles = try managedObjectContext.fetch(fetchRequest) as! [PatientProfile]
            fetchedCurrentUser = fetchedProfiles.first
        } catch {
        }
        for object in fetchedCurrentUser.medicines{
            let medicine:Medicine = object as! Medicine
            if(medicine.name == currentMedicine){
                fetchedCurrentMedicine = medicine
                medicineName = fetchedCurrentMedicine.name!
                medicineType = fetchedCurrentMedicine.type!
                dosageAmount = fetchedCurrentMedicine.dosage!
                navigationItem.title = medicineName
            }
        }
        
        medicineDetailTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            if(fetchedCurrentMedicine.alarms.count > 0){
                return fetchedCurrentMedicine.alarms.count
            }
            else{
                return 1
            }
        case 5:
            return 1
        case 6:
            return 1
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return ""
        case 1:
            return "Medicine Name"
        case 2:
            return "Medicine Type"
        case 3:
            return "Dosage Amount"
        case 4:
            return "Alarms"
        case 5:
            return ""
        case 6:
            return ""
        default:
            break
        }
        return "Error"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.section == 0){
            return 145
        }
        return 37
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 37
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            var cell: MedicineImageCustomCell! = tableView.dequeueReusableCell(withIdentifier: "medicineimagecustomcell") as? MedicineImageCustomCell
            if(cell == nil) {
                tableView.register(UINib(nibName: "MedicineImageCustomCell", bundle: nil), forCellReuseIdentifier: "medicineimagecustomcell")
                cell = tableView.dequeueReusableCell(withIdentifier: "medicineimagecustomcell") as? MedicineImageCustomCell
            }
            return cell
        }
        else if(indexPath.section == 4){
            if(fetchedCurrentMedicine.alarms.count > 0){
                var cell: NormalAlarmCustomCell! = tableView.dequeueReusableCell(withIdentifier: "normalalarmcustomcell") as? NormalAlarmCustomCell
                if(cell == nil) {
                    tableView.register(UINib(nibName: "NormalAlarmCustomCell", bundle: nil), forCellReuseIdentifier: "normalalarmcustomcell")
                    cell = tableView.dequeueReusableCell(withIdentifier: "normalalarmcustomcell") as? NormalAlarmCustomCell
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.none
                dateFormatter.timeStyle = DateFormatter.Style.short
                //let alarm:Alarm =  fetchedAlarms[indexPath.row] as! Alarm
                //print(alarm.time)
                return cell
            }
            else{
            }
        }
        else if(indexPath.section == 5){
            var cell: MedicineAddAlarmButtonCell! = tableView.dequeueReusableCell(withIdentifier: "medicineaddalarmbuttoncell") as? MedicineAddAlarmButtonCell
            if(cell == nil) {
                tableView.register(UINib(nibName: "MedicineAddAlarmButtonCell", bundle: nil), forCellReuseIdentifier: "medicineaddalarmbuttoncell")
                cell = tableView.dequeueReusableCell(withIdentifier: "medicineaddalarmbuttoncell") as? MedicineAddAlarmButtonCell
                cell.addAlarmsButton.addTarget(self, action: #selector(MedicineDetailViewController.addAlarmCellPressed), for: .touchUpInside)
            }
            return cell
        }
        else if(indexPath.section == 6){
            var cell: MedicineDeleteButtonCell! = tableView.dequeueReusableCell(withIdentifier: "medicinedeletebuttoncell") as? MedicineDeleteButtonCell
            if(cell == nil) {
                tableView.register(UINib(nibName: "MedicineDeleteButtonCell", bundle: nil), forCellReuseIdentifier: "medicinedeletebuttoncell")
                cell = tableView.dequeueReusableCell(withIdentifier: "medicinedeletebuttoncell") as? MedicineDeleteButtonCell
            }
            cell.deleteButton.addTarget(self, action: #selector(MedicineDetailViewController.deleteCurrentMedicine), for: .touchUpInside)
            return cell
        }
        var cell: MedicineDetailCustomCell! = tableView.dequeueReusableCell(withIdentifier: "medicinedetailcustomcell") as? MedicineDetailCustomCell
        if(cell == nil) {
            tableView.register(UINib(nibName: "MedicineDetailCustomCell", bundle: nil), forCellReuseIdentifier: "medicinedetailcustomcell")
            cell = tableView.dequeueReusableCell(withIdentifier: "medicinedetailcustomcell") as? MedicineDetailCustomCell
        }
        cell.textField.delegate = self
        switch indexPath.section{
        case 1:
            cell.textField.text = medicineName
        case 2:
            cell.textField.text = medicineType
        case 3:
            cell.textField.text = dosageAmount
        default:
            break
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    func addAlarmCellPressed(){
        performSegue(withIdentifier: "detailToAddAlarmSegue", sender: self)
    }
    
    func deleteCurrentMedicine(){
        let defaults = UserDefaults.standard
        let currentUser:String = defaults.value(forKey: "CurrentUser") as! String
        let predicate = NSPredicate(format: "name == %@", currentUser)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PatientProfile")
        fetchRequest.predicate = predicate
        var fetchedCurrentUser:PatientProfile!
        do {
            let fetchedProfiles = try managedObjectContext.fetch(fetchRequest) as! [PatientProfile]
            fetchedCurrentUser = fetchedProfiles.first
        } catch {
        }
        fetchedCurrentUser.removeMedicineObject(value: fetchedCurrentMedicine)
        managedObjectContext.delete(fetchedCurrentMedicine)
        do {
            try managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        navigationController?.popToRootViewController(animated: true)
    }
}
