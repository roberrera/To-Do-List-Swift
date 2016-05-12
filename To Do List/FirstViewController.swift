//
//  FirstViewController.swift
//  To Do List
//
//  Created by Robert M. Errera on 12/28/14.
//  Copyright (c) 2014 Robert M. Errera. All rights reserved.
//

import UIKit
import CoreData

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var taskName = [String]()
    var dueDate = [String]()
    var priorityLevel = [String]()
    var locationName = [String]()
    var tasks = [NSManagedObject]()
    var managedContext: NSManagedObjectContext!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet var tasksTable:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasksTable.dataSource = self
        tasksTable.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        // To recall the saved tasks.
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Tasks")
        
        do {
            let fetchResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            let results = fetchResults
            tasks = results
        } catch {
            let updateError = error as NSError
            print("\(updateError), \(updateError.userInfo)")
        }
 
        tasksTable.reloadData()
        print("Task list loaded successfully.")
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tasksTable.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let task = tasks[indexPath.row]
        cell.textLabel!.text = task.valueForKey("taskName") as! String?
        cell.detailTextLabel?.text = task.valueForKey("priorityLevel") as! String?
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

            switch editingStyle {
            case .Delete:
                // remove the deleted item from the model
                let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context:NSManagedObjectContext = appDel.managedObjectContext
                context.deleteObject(tasks[indexPath.row] as NSManagedObject)
                tasks.removeAtIndex(indexPath.row)
                do {
                    try context.save()
                } catch _ {
                }
            default:
                return

            }
            print("Task deleted.")

            // Update the task list.
            tasksTable.reloadData()
        }
    
    // called when 'return' key pressed.
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        // To make keyboard disappear when 'return' is pressed.
        textField.resignFirstResponder()
        return true
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Make keyboard disappear if a non-keyboard part of the screen is tapped.
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // This is the setup for segues.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Pass the selected object to the second view controller.
        if segue.identifier == "editTask" {
            let selectedItem = self.tasksTable.indexPathForSelectedRow
            let task = tasks[selectedItem!.row]
            let svc:SecondViewController = segue.destinationViewController as! SecondViewController

            svc.taskName = task.valueForKey ("taskName") as! String?
            svc.locationName = task.valueForKey ("locationName") as! String?
            svc.dueDate = task.valueForKey ("dueDate") as! String?
            svc.priorityLevel = task.valueForKey ("priorityLevel") as! String?
            svc.existingItem = task
        }
    }
    
    @IBAction func goBack(sender: UIStoryboardSegue) {}
    
}

