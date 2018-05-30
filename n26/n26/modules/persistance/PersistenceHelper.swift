//
//  PersistenceHelper.swift
//  AirTasker
//
//  Created by Timothy Storey on 27/01/2018.
//  Copyright © 2018 BITE-Software. All rights reserved.
//

import UIKit
import CoreData

class PersistenceHelper: NSObject {
    
    static func createProductionContainer (completion: @escaping(NSManagedObjectContext) -> ()) {
        let container = NSPersistentContainer(name: "AirTasks")
        container.loadPersistentStores { (_, error) in
            guard error == nil else {
                fatalError("Failed to load store: \(error!)")
            }
            DispatchQueue.main.async {
                completion(container.viewContext)
            }
        }
    }
}
