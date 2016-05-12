//
//  CoreDataStack.swift
//  To Do List
//
//  Created by Robert M. Errera on 12/28/14.
//  Copyright (c) 2014 Robert M. Errera. All rights reserved.
//

import Foundation
import CoreData


class CoreDataStack {
    
    let managedObjectModel: NSManagedObjectModel
    let storeCoordinator: NSPersistentStoreCoordinator
    let context: NSManagedObjectContext
    let store: NSPersistentStore?
    
    init() {
        let bundle = NSBundle.mainBundle()
        let modelURL = bundle.URLForResource("To_Do_List", withExtension: "momd")
        
        managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)!
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        context = NSManagedObjectContext()
        context.persistentStoreCoordinator = storeCoordinator
        
        let documentURL = applicationDocumentsDirectory()
        let storeURL = documentURL.URLByAppendingPathComponent("TasksModel")
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        
        var error: NSError? = nil
    
        do {
            store = try storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)
        } catch let error1 as NSError {
            error = error1
            store = nil
        }
        
        if store == nil{
            print("Error adding persistent store: \(error)")
            abort()
        }
    }
    
    func saveContext() {
        var error:NSError? = nil
        if context.hasChanges {
            do {
                try context.save()
            } catch let error1 as NSError {
                error = error1
                print("Could not save: \(error), \(error?.userInfo)")
            }
        }
    }
    
    func applicationDocumentsDirectory() -> NSURL  {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as [NSURL]
        return urls[0]
    }
}




