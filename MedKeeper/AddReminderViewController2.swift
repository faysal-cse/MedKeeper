//
//  AddReminderViewController2.swift
//  MedKeeper
//
//  Created by Jonathan Robins on 10/5/15.
//  Copyright © 2015 Round Robin Apps. All rights reserved.
//

import UIKit

class AddReminderViewController2: UIViewController{
  
    internal var medicineType: String = "";
    override func viewDidLoad() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pillButtonPressed(sender: AnyObject) {
        medicineType = "pill"
    }
    
    @IBAction func liquidButtonPressed(sender: AnyObject) {
        medicineType = "liquid"
    }
    
    internal func getMedicineType() -> String{
        return self.medicineType
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
