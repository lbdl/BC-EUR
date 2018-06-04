//
//  PersistenceManagerTests.swift
//  AirTasker
//
//  Created by Timothy Storey on 31/01/2018.
//  Copyright © 2018 BITE-Software. All rights reserved.
//

import Quick
import Nimble
import CoreData

@testable import n26

class PersistenceManagerTests: QuickSpec {
    
    
    override func spec() {
        
//        var sut: PersistenceManager!
//        var persistentContainer: ManagedContextProtocol?
        
//        func  flushDB() {
//            let fetchRequest = NSFetchRequest<Location>(entityName: "Location")
//            let objs = try! persistentContainer!.fetch(fetchRequest)
//            for case let obj as NSManagedObject in objs {
//                persistentContainer!.delete(obj)
//            }
//            try! persistentContainer!.save()
//        }
//        
//        afterEach {
//            flushDB()
//        }
//        
//        context("GIVEN a persistence manager instance") {
//            describe("WHEN we add objects") {
//                it("creates them via the object") {
//                    waitUntil { done in
//                        TestSuiteHelpers.createInMemoryContainer(completion: { (container) in
//                            persistentContainer = container
//                            sut = PersistenceManager(store: persistentContainer!)
//                            let testLoc = Location.insert(into: sut, raw: LocationRaw())
//                            expect(testLoc).toNot(beNil())
//                            done()
//                        })
//                    }
//                }
//                it("creates them via the manager") {
//                    waitUntil { done in
//                        TestSuiteHelpers.createInMemoryContainer(completion: { (container) in
//                            persistentContainer = container
//                            sut = PersistenceManager(store: persistentContainer!)
//                            let testLoc: Location = sut.insertObject()
//                            expect(testLoc).toNot(beNil())
//                            done()
//                        })
//                    }
//                }
//            }
//        }
//    }
//    // work around so that xcode9.2 actually see's the tests
//    // thanks apple for allowing us to test things
//    public func testDummy() {}
    }
}
