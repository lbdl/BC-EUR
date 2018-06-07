//
//  CurrencyPairPersistenceTest.swift
//  n26
//
//  Created by Timothy Storey on 05/06/2018.
//  Copyright © 2018 BITE-Software. All rights reserved.
//

import Quick
import Nimble
import CoreData

@testable import n26

class CurrencyPairPersistenceTest: QuickSpec {
    override func spec() {
        
        var rawData: Data?
        var sut: CurrencyMapper?
        var manager: PersistenceControllerProtocol?
        var persistentContainer: ManagedContextProtocol?
        
        func  flushDB() {
            let currencyRequest = NSFetchRequest<Currency>(entityName: "Currency")
            let currencies = try! persistentContainer!.fetch(currencyRequest)
            for case let obj as NSManagedObject in currencies {
                persistentContainer!.delete(obj)
                try! persistentContainer!.save()
            }
        }
        
        beforeSuite {
            rawData = TestSuiteHelpers.readLocalData(testCase: .rangedBpiData)
            TestSuiteHelpers.createInMemoryContainer(completion: { (container) in
                persistentContainer = container
                manager = PersistenceManager(store: persistentContainer!)
                sut = CurrencyMapper(storeManager: manager!)
            })
        }
        
        afterEach {
            //flushDB()
        }
        
        context("GIVEN a manager and valid BPI JSON"){
            describe("WHEN we parse valid JSON") {
                it("IT persists Currency objects to the backing store"){
                    waitUntil { done in
                        sut?.parse(rawBpiValue: rawData!)
                        sut?.persist(rawJson: (sut?.mappedValue)!)
                        let request = NSFetchRequest<Currency>(entityName: Currency.entityName)
                        let results = try! persistentContainer?.fetch(request)
                        expect(results).toNot(beNil())
                        done()
                    }
                }
                
                it ("IT persists 19 currency pairs only") {
                    waitUntil { done in
                        sut?.parse(rawValue: rawData!)
                        sut?.persist(rawJson: (sut?.mappedValue)!)
                        let request = NSFetchRequest<Currency>(entityName: Currency.entityName)
                        let results = try! persistentContainer?.fetch(request)
                        expect(results?.count).to(equal(19))
                        done()
                    }
                }
                it ("IT persists currencies with the correct properties") {
                    waitUntil { done in
                        sut?.parse(rawValue: rawData!)
                        sut?.persist(rawJson: (sut?.mappedValue)!)
                        let request = NSFetchRequest<Currency>(entityName: Currency.entityName)
                        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Currency.dayDate), "2018-05-10")
                        let results = try! persistentContainer?.fetch(request)
                        expect(results?.first).to(beAKindOf(Currency.self))
                        expect(results?.first?.dayDate).to(equal("2018-05-10"))
                        expect(results?.first?.rate).to(equal(7564.5511))
                        expect(results?.first?.desc).to(equal("Euro"))
                        expect(results?.first?.id).to(equal("EUR"))
                        expect(results?.first?.updatedISO.description).to(equal("2018-05-29 00:03:00 +0000"))
                        done()
                    }
                }
            }
        }
    }
}
