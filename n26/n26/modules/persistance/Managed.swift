//
//  Managed.swift
//  AirTasker
//
//  Created by Timothy Storey on 27/01/2018.
//  Copyright © 2018 BITE-Software. All rights reserved.
//

import Foundation
import CoreData

protocol Managed: class, NSFetchRequestResult {
    static var entityName: String { get }
}

extension Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    static var sortedFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
}

extension Managed where Self: NSManagedObject {
    static var entityName: String { return entity().name! }
    
    /// Allows for the creation of objects and configuration via the passed in configuration block
    /// if the object is not already in the store
    static func fetchOrCreate(fromManager manager: PersistenceControllerProtocol, matching predicate: NSPredicate, configure: (Self) -> ()) -> Self {
        guard let obj = findOrFetch(fromManager: manager, matching: predicate) else {
            let newObj: Self = manager.insertObject()
            configure(newObj)
            return newObj
        }
        return obj
    }
    
    static func findOrFetch(fromManager manager: PersistenceControllerProtocol, matching predicate: NSPredicate) -> Self? {
        guard let obj = volatileObject(fromManager: manager, matching: predicate) else {
            return fetch(fromManager: manager) { req in
                req.predicate = predicate
                req.returnsObjectsAsFaults = false
                req.fetchLimit = 1
                }.first
        }
        return obj
    }
    
    static func volatileObject(fromManager manager: PersistenceControllerProtocol, matching predicate: NSPredicate) -> Self? {
        for obj in manager.context.registeredObjects where !obj.isFault {
            guard let res = obj as? Self, predicate.evaluate(with: res) else {continue}
            return res
        }
        return nil
    }
    
    static func fetch(fromManager manager: PersistenceControllerProtocol, configBlock: (NSFetchRequest<Self>) -> () = {_ in}) -> [Self] {
        let req = NSFetchRequest<Self>(entityName: Self.entityName)
        configBlock(req)
        return try! manager.context.fetch(req)
    }

}






