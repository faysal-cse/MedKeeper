//
//  AddMedicineDosageViewController.swift
//  MedKeeper
//
//  Created by Jonathan Robins on 11/2/15.
//  Copyright © 2015 Round Robin Apps. All rights reserved.
//

import UIKit
import CoreData

class AddMedicineDosageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet var dosagePickerView: UIPickerView!
    @IBOutlet var dosageAmount: UITextField!
    var medicineType: String = "Pill"
    private var pillPickerViewData = ["Pills", "mg"]
    private var liquidPickerViewData = ["Tbsp", "tsp", "mL"]
    private var currentMeasurement = "Pills"
    var retrievedName : String  = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Enter Dosage"
        dosageAmount.keyboardType = .decimalPad
        dosageAmount.becomeFirstResponder()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(AddMedicineDosageViewController.doneButtonPressed))
        navigationItem.rightBarButtonItem = doneButton
        
        dosageAmount.delegate = self
        dosagePickerView.delegate = self
        dosagePickerView.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        if(medicineType == "Liquid"){
            currentMeasurement = "tsp"
            dosagePickerView.selectRow(1, inComponent: 0, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func doneButtonPressed(){
        if(dosageAmount.text == ""){
            let alert = UIAlertController(title: "Please enter a Dosage amount.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            //save medicine into coredata
            let managedContext = AppDelegate().managedObjectContext
            let entity =  NSEntityDescription.entity(forEntityName: "Medicine", in: managedContext)
            let medicine = NSManagedObject(entity: entity!, insertInto: managedContext)
            medicine.setValue(retrievedName, forKey: "name")
            medicine.setValue(medicineType, forKey: "type")
            if(dosageAmount.text == "1" && currentMeasurement == "Pills"){
                currentMeasurement = "Pill"
            }
            let dosageValue = dosageAmount.text! + " " + currentMeasurement
            medicine.setValue(dosageValue, forKey: "dosage")
            
            //save medicine to currentUser
            let defaults = UserDefaults.standard
            let currentUser:String = defaults.value(forKey: "CurrentUser") as! String
            let predicate = NSPredicate(format: "name == %@", currentUser)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PatientProfile")
            fetchRequest.predicate = predicate
            var fetchedCurrentUser:PatientProfile!
            do {
                let fetchedProfiles = try managedContext.fetch(fetchRequest) as! [PatientProfile]
                fetchedCurrentUser = fetchedProfiles.first
            } catch {
            }
            fetchedCurrentUser.addMedicineObject(value: medicine as! Medicine)
            
            //save contect
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            //set medicine as current medicine
            defaults.setValue(retrievedName, forKey: "CurrentMedicine")
            defaults.synchronize()

            navigationController?.popToRootViewController(animated: true)
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "alarmTypeVC") as! UINavigationController
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController!.present(vc, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(self.medicineType == "Pill"){
            return 2
        }
        else{
            return 3
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(self.medicineType == "Pill"){
            return pillPickerViewData[row]
        }
        else{
            return liquidPickerViewData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(medicineType == "Pill"){
            currentMeasurement = pillPickerViewData[row]
        }
        else{
            currentMeasurement = liquidPickerViewData[row]
        }
        print(currentMeasurement)
    }
    
    internal func setType(type: String){
        if(self.medicineType != type){
            self.medicineType = type
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 7 // Bool
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
