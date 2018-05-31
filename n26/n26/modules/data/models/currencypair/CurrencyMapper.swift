//
//  CurrencyMapper.swift
//  n26
//
//  Created by Timothy Storey on 30/05/2018.
//  Copyright © 2018 BITE-Software. All rights reserved.
//

import Foundation

class CurrencyMapper: JSONMappingProtocol {
    internal var decoder: JSONDecodingProtocol
    internal var mappedValue: MappedValue?
    internal var persistanceManager: PersistenceControllerProtocol
    
    typealias MappedValue = Mapped<CurrencyRaw>
    typealias raw = Data
    
    required init(storeManager: PersistenceControllerProtocol, decoder: JSONDecodingProtocol=JSONDecoder()) {
        persistanceManager = storeManager
        self.decoder = decoder
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    var rawValue: raw? {
        didSet {
            parse(rawValue: rawValue!)
        }
    }
    
    internal func parse(rawValue: Data) {
        do {
            let tmp = try decoder.decode(CurrencyRaw.self, from: rawValue)
            mappedValue = .Value(tmp)
        } catch let error {
            let tmp = error as! DecodingError
            mappedValue = .MappingError(tmp)
        }
    }
    
    internal func persist(rawJson: Mapped<CurrencyRaw>) {
        if let obj = rawJson.associatedValue() as? CurrencyRaw {
            persistanceManager.updateContext(block: {
                //_ = Localle.insert(into: self.persistanceManager, raw: obj)
            })
        }
    }
}
