//
//  AddNormalAlarmViewController.swift
//  MedKeeper
//
//  Created by Jonathan Robins on 11/8/15.
//  Copyright © 2015 Round Robin Apps. All rights reserved.
//

import UIKit
import CoreData

class AddNormalAlarmViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NormalAlarmCustomCellDelegate{


    @IBOutlet var addAlermBtn: UIButton!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var alarmTableView: UITableView!
    var alarmList: NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Add Normal Alarms"
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(AddNormalAlarmViewController.doneButtonPressed))
        navigationItem.rightBarButtonItem = doneButton
 
        alarmTableView.delegate = self
        alarmTableView.dataSource = self
        
        addAlermBtn.addTarget(self, action: #selector(addAlarmButtonPressed(sender:)), for: .touchUpInside)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addAlarmButtonPressed(sender: AnyObject) {
        //get date from date picker
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.none
        dateFormatter.timeStyle = DateFormatter.Style.short
        let alarmValueBeforeSecondsChange:NSDate = datePicker.date as NSDate
        let time:TimeInterval = floor(alarmValueBeforeSecondsChange.timeIntervalSinceReferenceDate/60.0) * 60.0
        let alarmValue:NSDate = NSDate.init(timeIntervalSinceReferenceDate: time)
        //add to alarm list of NSDates
        if(alarmList.contains(alarmValue)){
            let alert = UIAlertController(title: "Duplicate Alarm", message: "You've already added an alarm for that time.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            alarmList.insert(alarmValue, at: alarmList.count)
            alarmTableView.reloadData()
            let indexPath = NSIndexPath.init(row: alarmList.count-1, section: 0)
            alarmTableView.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    @objc func doneButtonPressed(){
        if(alarmList.count > 0){
            //save alarms to current medicine
            let managedContext = AppDelegate().managedObjectContext
            //get name of current medicine
            let defaults = UserDefaults.standard
            let currentMedicine : String = defaults.value(forKey: "CurrentMedicine") as! String
            //fetch for all medicines with name of currentMedicine
            let predicate = NSPredicate(format: "name == %@", currentMedicine)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Medicine")
            fetchRequest.predicate = predicate
            var fetchedCurrentMedicine:Medicine!
            do {
                let fetchedMedicines = try managedContext.fetch(fetchRequest) as! [Medicine]
                fetchedCurrentMedicine = fetchedMedicines.first
            } catch {
                
            }
            
            //add all the alarms to the Medicine class
            for alarmValue in alarmList{
                let entity =  NSEntityDescription.entity(forEntityName: "Alarm", in: managedContext)
                let alarm = NSManagedObject(entity: entity!, insertInto: managedContext) as! Alarm
                alarm.setValue("MWF", forKey: "weekdays")
                alarm.setValue(alarmValue as! NSDate, forKey: "time")
                fetchedCurrentMedicine.addAlarmObject(value: alarm)
                
                //create local notification
                let notification = UILocalNotification()
                notification.alertTitle = "MedKeeper Reminder"
                notification.alertBody = "TAKE YA " + (fetchedCurrentMedicine.name?.uppercased())!
                notification.alertAction = "Okay"
                notification.fireDate = alarm.time as! Date
                notification.soundName = "bell_ring.mp3"
                notification.category = "MEDICINES"
                UIApplication.shared.scheduleLocalNotification(notification)
            }

            do {
                //print(fetchedCurrentMedicine.alarms.count)
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            //go back to alarm timeline
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "No Alarms Set", message: "You haven't set any alarms for this medication.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarmList.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: NormalAlarmCustomCell! = tableView.dequeueReusableCell(withIdentifier: "normalalarmcustomcell") as? NormalAlarmCustomCell
            if(cell == nil) {
                tableView.register(UINib(nibName: "NormalAlarmCustomCell", bundle: nil), forCellReuseIdentifier: "normalalarmcustomcell")
                cell = tableView.dequeueReusableCell(withIdentifier: "normalalarmcustomcell") as? NormalAlarmCustomCell
            }
        let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.none
            dateFormatter.timeStyle = DateFormatter.Style.short
        cell.textLabel!.text = dateFormatter.string(from: (alarmList[indexPath.row] as! NSDate) as Date)
            cell.delegate = self;
            return cell
    }
    
    func deleteButtonPressed(cell: NormalAlarmCustomCell){
        let indexPath: NSIndexPath = alarmTableView.indexPath(for: cell)! as NSIndexPath
        alarmList.removeObject(at: indexPath.row)
        alarmTableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.left)
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
