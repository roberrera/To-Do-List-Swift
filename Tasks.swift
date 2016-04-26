//
//  Tasks.swift
//  To Do List
//
//  Created by Robert M. Errera on 1/3/15.
//  Copyright (c) 2015 Robert M. Errera. All rights reserved.
//

import Foundation
import CoreData

@objc(Tasks)
class Tasks: NSManagedObject {

    @NSManaged var taskName: String
    @NSManaged var dueDate: String
    @NSManaged var priorityLevel: String
    @NSManaged var locationName: String

}

