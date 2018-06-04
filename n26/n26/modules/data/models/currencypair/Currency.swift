//
//  Currency.swift
//  n26
//
//  Created by Timothy Storey on 31/05/2018.
//  Copyright © 2018 BITE-Software. All rights reserved.
//

import Foundation
import CoreData

final class Currency: NSManagedObject {
    @NSManaged fileprivate(set) var id: String
    @NSManaged fileprivate(set) var dayDate: String
    @NSManaged fileprivate(set) var desc: String
    @NSManaged fileprivate(set) var rate: Float
    @NSManaged fileprivate(set) var updatedISO: Date
    
    static var dateFormatter = DateFormatter()
    
    static func insert(into manager: PersistenceControllerProtocol, raw: CurrencyRaw) -> Currency {
        let currency: Currency = Currency.fetchCurrency(forDate: raw.updatedAt, fromManager: manager)
        //if rate is 0 then it's a new object
        if currency.rate == 0 {
            currency.rate = raw.currencyRate
            currency.desc = raw.currencyDescription
            currency.id = raw.id
        } else {
            currency.updatedISO = raw.updatedAt
            return currency
        }
        return currency
    }
    
    static func fetchCurrency(forDate updateDate: Date, fromManager manager: PersistenceControllerProtocol) -> Currency {
        //set dateString
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: updateDate)
        let predicate = NSPredicate(format: "%K == %@", #keyPath(dayDate), dateString)
        let currency = fetchOrCreate(fromManager: manager, matching: predicate) { curr in
            if curr.dayDate != dateString {
                curr.dayDate = dateString
            }
        }
        return currency
    }
}

extension Currency: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(id), ascending: true)]
    }
    
    // overidden to stop odd test failures using in memory store DB
    // which doesn't seem to tidy itself up properly
    // nor always load the models. This only happens
    // when running the entoire test suite, individual sets of
    // tests run fine. Sigh...
    static var entityName = "Currency"
}
