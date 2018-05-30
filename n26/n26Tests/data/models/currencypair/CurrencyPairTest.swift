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

class CurrencyPairTest: QuickSpec {
    override func spec() {
        
        var rawData: Data?
        var sut: CurrencyMapper
        var manager: PersistenceControllerProtocol?
        var persistentContainer: ManagedContextProtocol?

        beforeSuite {
            rawData = TestSuiteHelpers.readLocalData(testCase: .currencyPair)
        }
        afterSuite {
            rawData = nil
        }
        afterEach {
        }
        
        context("GIVEN a Mapper and JSON") {
            //
        }
    }
}
