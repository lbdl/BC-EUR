//
//  PersistenceManager.swift
//  AirTasker
//
//  Created by Timothy Storey on 25/01/2018.
//  Copyright © 2018 BITE-Software. All rights reserved.
//

import UIKit
import CoreData

protocol PersistenceControllerProtocol {
    var context: ManagedContextProtocol {get}
    func updateContext(block: @escaping () -> ())
    func insertObject<A>() -> A where A: Managed
}

protocol ManagedContextProtocol {
    var registeredObjects: Set<NSManagedObject> {get}
    func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T]
    func save() throws
    func delete(_ object: NSManagedObject)
    func rollback()
}

extension NSManagedObjectContext: ManagedContextProtocol {}


class PersistenceManager: NSObject, PersistenceControllerProtocol {
    
    //private let container: NSPersistentContainer
    let context: ManagedContextProtocol
    
    required init(store: ManagedContextProtocol) {
        //container = store
        context = store
    }
    
    public func updateContext(block: @escaping () -> ()) {
        block()
        _ = self.saveOrRestore()
    }
    
    internal func saveOrRestore () -> Bool {
        do {
            try context.save()
            return true
        } catch let error as NSError{
            print(error)
            context.rollback()
            return false
        }
    }
    
    public func insertObject<A>() -> A where A : Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: context as! NSManagedObjectContext) as? A else {
            fatalError("Could not insert object")
        }
        return obj
    }
}

