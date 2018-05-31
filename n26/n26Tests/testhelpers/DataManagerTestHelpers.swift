//
//  DataManagerTestHelpers.swift
//  n26Tests
//
//  Created by Timothy Storey on 24/02/2018.
//  Copyright © 2018 BITE-Software. All rights reserved.
//

import Foundation

@testable import n26

class MockURLSession: URLSessionProtocol {
    
    var nextDataTask = MockURLSessionDataTask()
    var testData: Data?
    var testError: Error?
    var testResponse: URLResponse?
    private (set) var lastURL: URL?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskHandler) -> URLSessionDataTaskProtocol {
        lastURL = request.url
        testResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
        completionHandler(testData, testResponse, testError)
        return nextDataTask
    }
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false
    func resume() {
        resumeWasCalled = true
    }
}

class MockCurrencyParser: JSONMappingProtocol {
    var persistanceManager: PersistenceControllerProtocol
    typealias MappedValue = Mapped<CurrencyRaw>
    var decoder: JSONDecodingProtocol
    var data: Data?
    var mappedValue: MappedValue?
    var receivedData: Data?
    var didCallMap: Bool?
    var didCallPersist: Bool?
    
    func parse(rawValue: Data) {
        receivedData = rawValue
        didCallMap = true
        _ = try! decoder.decode(CurrencyRaw.self, from: rawValue)
        mappedValue = .Value(CurrencyRaw())
    }
    
    func persist(rawJson: Mapped<CurrencyRaw>) {
        didCallPersist = true
    }
    
    init() {
        decoder = MockCurrencyJSONDecoder()
        persistanceManager = MockPersistenceManager(managedContext: MockManagedContext())
    }
}

class MockCurrencyJSONDecoder: JSONDecodingProtocol {
    
    var didCallSetStrategy: Bool?
    var didCallDecode: Bool?
    
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        set {
            self.dateDecodingStrategy = newValue
            didCallSetStrategy = true
        }
        get {
            return self.dateDecodingStrategy
        }
    }
    
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        didCallDecode = true
        let tmp = CurrencyRaw()
        return tmp as! T
    }
    
    
}






