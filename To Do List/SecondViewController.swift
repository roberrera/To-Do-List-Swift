//
//  SecondViewController.swift
//  To Do List
//
//  Created by Robert M. Errera on 12/28/14.
//  Copyright (c) 2014 Robert M. Errera. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class SecondViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate {

//    @IBAction func cancelButton(sender: AnyObject)
//    {
//        // Dismiss view and go back.
//        dismissViewControllerAnimated(true, completion: nil)
//    }

    var task:AnyObject!
    var indexPath:NSIndexPath!
    var tasks = [NSManagedObject]()
    var taskName:String?
    var dueDate:String?
    var priorityLevel:String?
    var locationName:String?
    var existingItem:NSManagedObject!
    let locationManager = CLLocationManager()

    @IBOutlet weak var taskTitleText: UITextField!
    @IBOutlet weak var priorityLevelText: UITextField!

    // For displaying user's current location.
    @IBOutlet weak var currentAddress: UILabel!

    func locationManager(manager: CLLocationManager, didUpdateLocations locations:
        [CLLocation]) {
            CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error) -> Void in
                
                if (error != nil)
                {
                    print("“Reverse geocoder failed with error ” + \(error.localizedDescription)")
                    return
                }
                
                if placemarks.count > 0
                {
                    let pm = placemarks[0] as CLPlacemark
                    self.displayLocationInfo(pm)
                    print("displayLocationInfo called.")
               
                } else {
                    print("There was a problem with the geocoder.")
                }
            })
    }
    
    func displayLocationInfo(placemark: CLPlacemark!) {
        if (placemark != nil)
        {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            print("Location has finished loading.")
            
            var userLocation:String = ""
            
            if (placemark.thoroughfare != nil)
            {
                userLocation = userLocation + placemark.thoroughfare + ","
            }
            if (placemark.subThoroughfare != nil)
            {
                userLocation = userLocation + placemark.subThoroughfare + ","
            }
            if (placemark.locality != nil)
            {
                userLocation = userLocation + placemark.locality + ","
            }
            if (placemark.administrativeArea != nil)
            {
                userLocation = userLocation + placemark.administrativeArea + ","
            }
            if (placemark.postalCode != nil)
            {
                userLocation = userLocation + placemark.postalCode
            }

//            if (placemark.country != nil)
//            {
//                userLocation = userLocation + placemark.country + "\n"
//            }
            print("\(placemark.locality)" + ", etc.")
            currentAddress?.text = userLocation

        }
    }
   
    @IBAction func currentLocationButton(sender: AnyObject)
    {
        // Core Location data.
        
        locationManager.delegate = self
        
        // To use most accurate location, even though it will use more battery.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Authorization request. Only comes up on first run.
        locationManager.requestWhenInUseAuthorization()
        
        // Actually update the user's location.
        locationManager.startUpdatingLocation()
        print("Location is being updated.")
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        print("Location is loading.")
        
//        currentAddress.text = self.userLocation

}

    // Setting up date picker and connected label.
    @IBOutlet weak var dueDateText: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // Save to core data.
    @IBAction func saveItemButton(sender: AnyObject)
    {
        // CORE DATA
        
        // Add an item to the task list and make the keyboard disappear once you press "Save".
        
        // Set up reference to app delegate.
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Set up reference to managed object context.
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName("Tasks", inManagedObjectContext:managedContext)
        
        // Checking if item exists.
        if existingItem != nil {
            existingItem.setValue(taskTitleText?.text, forKey: "taskName")
            existingItem.setValue(currentAddress?.text, forKey: "locationName")
            existingItem.setValue(dueDateText?.text, forKey: "dueDate")
            existingItem.setValue(priorityLevelText?.text, forKey: "priorityLevel")
        } else {

        // Create instance of and initialize data model.
        let task = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)

        // Map the properties.
        task.setValue(taskTitleText?.text, forKey: "taskName")
        task.setValue(currentAddress?.text, forKey: "locationName")
        task.setValue(dueDateText?.text, forKey: "dueDate")
        task.setValue(priorityLevelText?.text, forKey: "priorityLevel")
        }
        
        
        var error:NSError?
        
        if !managedContext.save(&error)
        {
            print("Could not save \(error), \(error?.userInfo)")
        }
        
        // Save the context.
        appDelegate.coreDataStack.saveContext()
        print("'appDelegate.coreDataStack.saveContext()' set.")
        
        // Add the new item to the task list.
//        tasks.append(task)
            print("Task saved.")
        
        // Make keyboard disappear when 'add item' button is pressed, and go back to the task list.
        self.view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
//            println(tasks)

    }

    // Update the due date text field when the date picker is changed.
    func datePickerDateChanged(datePicker: UIDatePicker){
//        println("Selected date = \(datePicker.date)")
        let dateFormatter = NSDateFormatter()
//            println("dateformatter....")
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm"
        let theDate = dateFormatter.stringFromDate(datePicker.date)
//                println("stringFromDate.....")
        dueDateText.text = theDate
                print("Due date selected.")
                print("Due date = \(datePicker.date)")
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This is here to make sure no entity classes turn up as nil.
        if currentAddress?.text == nil {
            currentAddress?.text = "<Current Location>"
        }
        if dueDateText?.text == nil {
            dueDateText?.text = "<Due date>"
        }
        print("default text set.")
        
        datePicker.addTarget(self, action: "datePickerDateChanged:", forControlEvents: .ValueChanged)
        
        // If you tap on an existing task item, the second view controller will allow you to update the item.
        if (existingItem != nil) {
            taskTitleText?.text = taskName
            priorityLevelText?.text = priorityLevel
            dueDateText?.text = dueDate
            currentAddress?.text = locationName
        }
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        // To make keyboard disappear when 'return' is pressed.
        textField.resignFirstResponder()
        return true
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        // Make keyboard disappear if a non-keyboard part of the screen is tapped.
        self.view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    @IBAction func goBack(sender: UIStoryboardSegue) {
    }

}