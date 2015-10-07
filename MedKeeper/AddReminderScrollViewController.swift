//
//  AddReminderScrollViewController.swift
//  MedKeeper
//
//  Created by Jonathan Robins on 10/4/15.
//  Copyright © 2015 Round Robin Apps. All rights reserved.
//

import UIKit

class AddReminderScrollViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var nextButton: UIButton!
    let vc0 = AddReminderViewController1(nibName: "AddReminderView1", bundle: nil);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        loadViewControllersIntoScrollView();
        checkScrollViewOffset();
    }
    
    override func viewDidLayoutSubviews() {
        self.vc0.nameField.becomeFirstResponder();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadViewControllersIntoScrollView(){
        //First Controller
        vc0.view.frame = self.scrollView.bounds;
        
        self.addChildViewController(vc0);
        self.scrollView.addSubview(vc0.view);
        self.vc0.didMoveToParentViewController(self);
        self.vc0.nameField.delegate = self;
        
        //Second Controller
        let vc1 = AddReminderViewController2(nibName: "AddReminderView2", bundle: nil);
        
        var frame1 = self.scrollView.bounds;
        frame1.origin.x = self.view.frame.size.width;
        vc1.view.frame = frame1;
        
        self.addChildViewController(vc1);
        self.scrollView.addSubview(vc1.view);
        vc1.didMoveToParentViewController(self);
        
        //Third Controller
        let vc2 = AddReminderViewController3(nibName: "AddReminderView3", bundle: nil);
        
        var frame2 = self.scrollView.bounds;
        frame2.origin.x = self.view.frame.size.width*2;
        vc2.view.frame = frame2;
        
        self.addChildViewController(vc2);
        self.scrollView.addSubview(vc2.view);
        vc2.didMoveToParentViewController(self);
        
        //Fourth Controller
        let vc3 = AddReminderViewController4(nibName: "AddReminderView4", bundle: nil);
        
        var frame3 = self.scrollView.bounds;
        frame3.origin.x = self.view.frame.size.width*3;
        vc3.view.frame = frame3;
        
        self.addChildViewController(vc3);
        self.scrollView.addSubview(vc3.view);
        vc3.didMoveToParentViewController(self);
        
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width*4, self.view.frame.size.height - 250);
    }
    
    @IBAction func next(sender: AnyObject) {
        if(self.vc0.nameField.isFirstResponder()){
            self.vc0.nameField.resignFirstResponder();
            self.scrollView.scrollEnabled = true;
        }
        
        let x = self.scrollView.contentOffset.x;
        switch(x){
        case 0:
            self.scrollView.contentOffset = CGPoint(x: self.view.frame.size.width, y: 0);
            break;
        case self.view.frame.size.width:
            self.scrollView.contentOffset = CGPoint(x: self.view.frame.size.width*2, y: 0);
            break;
        case self.view.frame.size.width*2:
            self.scrollView.contentOffset = CGPoint(x: self.view.frame.size.width*3, y: 0);
            break;
        case self.view.frame.size.width*3:
            break;
        default:
            break;
        }
        checkScrollViewOffset();
    }
    
    @IBAction func back(sender: AnyObject) {
        
        let x = self.scrollView.contentOffset.x;
        switch(x){
        case 0:
            break;
        case self.view.frame.size.width:
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0);
            break;
        case self.view.frame.size.width*2:
            self.scrollView.contentOffset = CGPoint(x: self.view.frame.size.width, y: 0);
            break;
        case self.view.frame.size.width*3:
            self.scrollView.contentOffset = CGPoint(x: self.view.frame.size.width*2, y: 0);
            break;
        default:
            break;
        }
        checkScrollViewOffset();
        
    }
    
    func checkScrollViewOffset(){
        if(self.scrollView.contentOffset.x == 0){
            self.backButton.hidden = true;
        }
        else{
            self.backButton.hidden = false;
        }
        
        if(self.scrollView.contentOffset.x == self.view.frame.size.width*3){
            self.nextButton.hidden = true;
        }
        else{
            self.nextButton.hidden = false;
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField == self.vc0.nameField){
            self.scrollView.scrollEnabled = false;
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == self.vc0.nameField){
            self.vc0.nameField.resignFirstResponder();
            self.scrollView.scrollEnabled = true;
        }
        return true
    }
    
}