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
        let currency: Currency = Currency.fetchCurrency(forDate: raw.dayDate, fromManager: manager)
        //if rate and daydate match then do nothing else update object
        if currency.rate != raw.currencyRate && currency.dayDate != raw.dayDate {
            currency.rate = raw.currencyRate
            currency.desc = raw.currencyDescription
            currency.id = raw.id
            currency.dayDate = raw.dayDate
        }
        currency.updatedISO = raw.updatedAt
        return currency
    }
    
    static func fetchCurrency(forDate dateString: String, fromManager manager: PersistenceControllerProtocol) -> Currency {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(dayDate), dateString)
        let currency = fetchOrCreate(fromManager: manager, matching: predicate) { curr in
//            if curr.dayDate != dateString {
//                curr.dayDate = dateString
//            }
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
    // when running the entire test suite, individual sets of
    // tests run fine. Sigh...
    static var entityName = "Currency"
}
