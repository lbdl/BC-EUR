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
    internal var dateFormatter: DateFormatter
    internal var formatString = "yyyy-MM-dd"
    
    typealias MappedValue = Mapped<[CurrencyRaw]>
    typealias raw = Data
    
    required init(storeManager: PersistenceControllerProtocol, decoder: JSONDecodingProtocol=JSONDecoder()) {
        persistanceManager = storeManager
        self.decoder = decoder
        self.decoder.dateDecodingStrategy = .iso8601
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
    }
    
    var rawValue: raw? {
        didSet {
            parse(rawValue: rawValue!)
        }
    }
    
    var rawBPIValue: raw? {
        didSet {
            parse(rawBpiValue: rawBPIValue!)
        }
    }
    
    internal func parse(rawBpiValue: Data) {
        do {
            let tmp = try decoder.decode(BPIRaw.self, from: rawBpiValue)
            var tmpCurrencies = [CurrencyRaw]()
            for rawBPI in tmp.rawBPIs {
                let tmpCurr = CurrencyRaw(rawBpi: rawBPI)
                tmpCurrencies.append(tmpCurr)
            }
            mappedValue = .Value(tmpCurrencies)
        } catch  let error{
            let tmp = error as! DecodingError
            mappedValue = .MappingError(tmp)
        }
    }
    
    internal func parse(rawValue: Data) {
        do {
            let tmp = try decoder.decode(CurrencyRaw.self, from: rawValue)
            mappedValue = .Value([tmp])
        } catch let error {
            let tmp = error as! DecodingError
            mappedValue = .MappingError(tmp)
        }
    }
    
    internal func persist(rawJson: Mapped<[CurrencyRaw]>) {
        if let obj = rawJson.associatedValue() as? [CurrencyRaw] {
            persistanceManager.updateContext(block: {
                _ = obj.map({ [weak self] currencyRaw in
                    guard let strongSelf = self else { return }
                    let curr = Currency.insert(into: strongSelf.persistanceManager, raw: currencyRaw)
                })
            })
        }
    }
}
