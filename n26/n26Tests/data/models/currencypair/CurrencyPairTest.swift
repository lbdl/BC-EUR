//
//  CurrencyPairTest.swift
//  n26
//
//  Created by Timothy Storey on 30/05/2018.
//Copyright © 2018 BITE-Software. All rights reserved.
//

import Quick
import Nimble

@testable import n26

//MARK: - Custom Matchers for associated values
private func beDecodingError(test: @escaping (Error) -> Void = { _ in }) -> Predicate<Mapped<CurrencyRaw>> {
    return Predicate.define("be decoding error") { expression, message in
        if let actual = try expression.evaluate(),
            case let .MappingError(Error) = actual {
            test(Error)
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}

private func beCurrency(test: @escaping (CurrencyRaw) -> Void = { _ in }) -> Predicate<Mapped<CurrencyRaw>> {
    return Predicate.define("be currency") { expression, message in
        if let actual = try expression.evaluate(),
            case let .Value(locations) = actual {
            test(locations)
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
        }
        afterEach {
        }
        
        context("GIVEN a Mapper and JSON") {
            describe("When we parse a valid JSON structure", {
                it("Creates a currency struct") {
                    waitUntil { done in
                        sut?.parse(rawValue: rawData!)
                        expect(sut?.mappedValue).to(beCurrency { currency in
                            expect(currency).to(beAKindOf(CurrencyRaw.self))
                        })
                        done()
                    }
                }
                
                it("Creates a struct with the correct date") {
                    waitUntil { done in
                        sut?.parse(rawValue: rawData!)
                        expect(sut?.mappedValue).to(beCurrency { currency in
                            expect(currency.updatedAt.description).to(equal("2018-05-29 15:49:00 +0000"))
                        })
                        done()
                    }
                }
                it("Creates a struct with the correct float rate"){
                    waitUntil { done in
                        sut?.parse(rawValue: rawData!)
                        expect(sut?.mappedValue).to(beCurrency { currency in
                            expect(currency.currencyRate).to(beAKindOf(Float.self))
                            expect(currency.currencyRate).to(equal(6420.51855))
                        })
                        done()
                    }
                }
                it("Creates a struct with the correct description"){
                    waitUntil { done in
                        sut?.parse(rawValue: rawData!)
                        expect(sut?.mappedValue).to(beCurrency { currency in
                            expect(currency.currencyDescription).to(equal("Euro"))
                        })
                        done()
                    }
                }
                it("Creates a struct with the correct identifier"){
                    waitUntil { done in
                        sut?.parse(rawValue: rawData!)
                        expect(sut?.mappedValue).to(beCurrency { currency in
                            expect(currency.id).to(equal("EUR"))
                        })
                        done()
                    }
                }
            })
        }
    }
}
