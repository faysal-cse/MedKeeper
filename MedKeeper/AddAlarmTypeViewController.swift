//
//  AddAlarmTypeViewController.swift
//  MedKeeper
//
//  Created by Jonathan Robins on 11/7/15.
//  Copyright © 2015 Round Robin Apps. All rights reserved.
//

import UIKit

class AddAlarmTypeViewController: UIViewController {
    
    @IBOutlet var intervalBtn: UIButton!
    @IBOutlet var normalBtn: UIButton!
    @IBOutlet var addedMedicineCompletionLabel: UILabel!
    @IBOutlet var addAlarmsLateButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Add an Alarm"
        /*let backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton*/
        
        //set medicine name in label
        let defaults = UserDefaults.standard
        let currentMedicine : String = defaults.value(forKey: "CurrentMedicine") as! String
        let attributedString:NSMutableAttributedString = NSMutableAttributedString(string:"If you'd like to set an alarm for your medicine, " + currentMedicine + ", choose the type of alarm that best fits your needs.")
        attributedString.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17)], range: NSRange(location: 49, length: currentMedicine.characters.count))

        addedMedicineCompletionLabel.attributedText = attributedString
        
        //if user doesnt want to add alarms yet
        let underlineAttribute = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: "I'll add some alarms later...", attributes: underlineAttribute)
        addAlarmsLateButton.titleLabel!.attributedText = underlineAttributedString
        
        addAlarmsLateButton.addTarget(self, action: #selector(addAlarmsLaterButtonsPressed(sender:)), for: .touchUpInside)
        
         normalBtn.addTarget(self, action: #selector(normalAlarmButtonPressed(sender:)), for: .touchUpInside)
        
        intervalBtn.addTarget(self, action: #selector(intervalAlarmButtonPressed(sender:)), for: .touchUpInside)
    }
    
    @IBAction func normalAlarmButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func intervalAlarmButtonPressed(sender: AnyObject) {
    }

    @IBAction func addAlarmsLaterButtonsPressed(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }    
}
