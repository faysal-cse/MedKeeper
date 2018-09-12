//
//  AddMedicineNameAndTypeViewController.swift
//  MedKeeper
//
//  Created by Jonathan Robins on 11/2/15.
//  Copyright © 2015 Round Robin Apps. All rights reserved.
//

import UIKit
import CoreData

class AddMedicineNameAndTypeViewController: UIViewController {
    
    @IBOutlet var medicineNameTextField: UITextField!
    @IBOutlet var typeSegmentController: UISegmentedControl!
    var currentSegmentControlIndex = 0;
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Add a Medication"
        
        medicineNameTextField.becomeFirstResponder()
        
        let backButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(AddMedicineNameAndTypeViewController.cancelButtonPressed))
        navigationItem.leftBarButtonItem = backButton
        
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(AddMedicineNameAndTypeViewController.nextButtonPressed))
        navigationItem.rightBarButtonItem = nextButton
        
        typeSegmentController.addTarget(self, action: #selector(segmentedControlChanged(sender:)), for: .valueChanged)
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func nextButtonPressed(){
        //check that textfield isnt blank
        if(medicineNameTextField.text == ""){
            let alert = UIAlertController(title: "Please enter a Medicine name.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            //check that this medicine name hasnt been registered before
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Medicine")
            var nameNotTaken:Bool = true
            do {
                let results =
                    try managedObjectContext.fetch(fetchRequest)
                let medicineArray:NSArray = results as! [NSManagedObject] as NSArray
                for medicine in medicineArray{
                    let fetchedMedicine = medicine as! Medicine
                    if(fetchedMedicine.name == medicineNameTextField.text){
                        let alert = UIAlertController(title: "Medicine name already taken!", message: "Please enter a different medicine name.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        nameNotTaken = false
                    }
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            if(nameNotTaken){
                performSegue(withIdentifier: "segueToDosage", sender: self)
            }
        }
    }
    
    @objc func cancelButtonPressed(){
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentSegmentControlIndex = 0
        case 1:
            currentSegmentControlIndex = 1
        default:
            break;
        
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC : AddMedicineDosageViewController = (segue.destination as? AddMedicineDosageViewController)!
        if(currentSegmentControlIndex == 0){
            destVC.setType(type: "Pill")
        }
        else{
            destVC.setType(type: "Liquid")
        }
        destVC.retrievedName = medicineNameTextField.text as String!
        print(destVC.retrievedName)
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
