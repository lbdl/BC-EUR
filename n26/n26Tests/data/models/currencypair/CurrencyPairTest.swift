//
//  CurrencyPairTest.swift
//  n26
//
//  Created by Timothy Storey on 30/05/2018.
//  Copyright © 2018 BITE-Software. All rights reserved.
//

import Quick
import Nimble

@testable import n26

//MARK: - Custom Matchers for associated values used in the Mapped generic type
private func beDecodingError(test: @escaping (Error) -> Void = { _ in }) -> Predicate<Mapped<[CurrencyRaw]>> {
    return Predicate.define("be decoding error") { expression, message in
        if let actual = try expression.evaluate(),
            case let .MappingError(Error) = actual {
            test(Error)
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}

private func beCurrency(test: @escaping ([CurrencyRaw]) -> Void = { _ in }) -> Predicate<Mapped<[CurrencyRaw]>> {
    return Predicate.define("be currency") { expression, message in
        if let actual = try expression.evaluate(),
            case let .Value(currencies) = actual {
            test(currencies)
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}

class CurrencyPairTest: QuickSpec {
    
    override func spec() {
        
        var rawData: Data?
        var sut: CurrencyMapper?
        var manager: PersistenceControllerProtocol?
        var persistentContainer: ManagedContextProtocol?

        beforeSuite {
            rawData = TestSuiteHelpers.readLocalData(testCase: .currencyPair)
            TestSuiteHelpers.createInMemoryContainer(completion: { (container) in
                persistentContainer = container
                manager = MockPersistenceManager(managedContext: persistentContainer!)
                sut = CurrencyMapper(storeManager: manager!)
            })
        }
        
        afterSuite {
            rawData = nil
            persistentContainer = nil
            manager = nil
            sut = nil
        }
        
        afterEach {
        }
        
        context("GIVEN a CurencyMapper and JSON") {
            describe("WHEN we parse a valid JSON structure", {
                it("IT creates a currency struct") {
                    waitUntil { done in
                        sut?.parse(rawValue: rawData!)
                        expect(sut?.mappedValue).to(beCurrency { currencies in
                            expect(currencies).to(beAKindOf(Array<CurrencyRaw>.self))
                        })
                        done()
                    }
                }
                
                it("IT creates a struct with the correct date") {
                    waitUntil { done in
                        sut?.parse(rawValue: rawData!)
                        expect(sut?.mappedValue).to(beCurrency { currencies in
                            expect(currencies.first?.updatedAt.description).to(equal("2018-05-29 15:49:00 +0000"))
                        })
                        done()
                    }
                }
                it("IT creates a struct with the correct float rate"){
                    waitUntil { done in
                        sut?.parse(rawValue: rawData!)
                        expect(sut?.mappedValue).to(beCurrency { currencies in
                            expect(currencies.first?.currencyRate).to(beAKindOf(Float.self))
                            expect(currencies.first?.currencyRate).to(equal(6420.51855))
                        })
                        done()
                    }
                }
                it("IT creates a struct with the correct description"){
                    waitUntil { done in
                        sut?.parse(rawValue: rawData!)
                        expect(sut?.mappedValue).to(beCurrency { currencies in
                            expect(currencies.first?.currencyDescription).to(equal("Euro"))
                        })
                        done()
                    }
                }
                it("IT creates a struct with the correct identifier"){
                    waitUntil { done in
                        sut?.parse(rawValue: rawData!)
                        expect(sut?.mappedValue).to(beCurrency { currencies in
                            expect(currencies.first?.id).to(equal("EUR"))
                        })
                        done()
                    }
                }
            })
            
            context("GIVEN a BPIMapper and valid BPI JSON") {
                
                var bpiData: Data?
                
                beforeEach {
                    bpiData = TestSuiteHelpers.readLocalData(testCase: .rangedBpiData)
                }
                
                afterEach {
                    bpiData = nil
                }
                
                describe("WHEN we parse a valid BPI date ranged JSON structure", {
                    it("IT creates a currency struct") {
                        waitUntil { done in
                            sut?.parse(rawBpiValue: bpiData!)
                            expect(sut?.mappedValue).to(beCurrency { currencies in
                                expect(currencies).to(beAKindOf(Array<CurrencyRaw>.self))
                            })
                            done()
                        }
                    }
                    it("IT creates an array with the correct count of objects") {
                        waitUntil { done in
                            sut?.parse(rawBpiValue: bpiData!)
                            expect(sut?.mappedValue).to(beCurrency { currencies in
                                expect(currencies.count).to(equal(19))
                            })
                            done()
                        }
                    }
                    
                    it("IT creates the correct objects with the correct properties"){
                        waitUntil { done in
                            sut?.parse(rawBpiValue: bpiData!)
                            expect(sut?.mappedValue).to(beCurrency { currencies in
                                expect(currencies.first?.currencyDescription).to(equal("Euro"))
                                expect(currencies.first?.id).to(equal("EUR"))
                                expect(currencies.first?.updatedAt.description).to(equal("2018-05-29 00:03:00 +0000"))
                                expect(currencies.first?.dayDate).to(equal("2018-05-24"))
                                expect(currencies.first?.currencyRate).to(equal(6465.738))
                            })
                            done()
                        }
                    }
                })
            }
            
            context("GIVEN bad CURRENCY JSON") {
                
                var badData: Data?
                
                beforeEach {
                    badData = TestSuiteHelpers.readLocalData(testCase: .badCurrencyData)
                }
                
                afterEach {
                    badData = nil
                }
                
                describe("WHEN we parse") {
                    it("Returns an error") {
                        waitUntil { done in
                            sut?.parse(rawValue: badData!)
                            expect(sut?.mappedValue).to(beDecodingError())
                            done()
                        }
                    }
                }
                
            }
        }
    }
}
