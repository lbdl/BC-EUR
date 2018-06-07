//
//  CurrencyRaw.swift
//  n26
//
//  Created by Timothy Storey on 30/05/2018.
//  Copyright © 2018 BITE-Software. All rights reserved.
//

import Foundation

struct BPIRaw {
    
    struct Bpi {
        let floatValue: Float
        let dateString: String
        let updatedAt: Date
    }
    enum rangedBPIKeys: String, CodingKey {
        case bpi, time
    }
    
    enum TimeKeys: String, CodingKey {
        case updatedISO
    }
    
    let rawBPIs: [Bpi]
}

extension BPIRaw: Decodable {
    
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: rangedBPIKeys.self)
        let timeContainer = try container.nestedContainer(keyedBy: TimeKeys.self, forKey: .time)
        let time = try timeContainer.decode(Date.self, forKey: .updatedISO)
        let bpiContainer = try container.nestedContainer(keyedBy: AdditionalCodingKeys.self, forKey: .bpi)
        var raws = [Bpi]()
        for key in bpiContainer.allKeys {
            let val = try!  bpiContainer.decode(Float.self, forKey: key)
            let tmpBPI = Bpi(floatValue: val, dateString: key.stringValue, updatedAt: time)
            raws.append(tmpBPI)
        }
        rawBPIs = raws
    }
    
}

private struct AdditionalCodingKeys: CodingKey
{
    var intValue: Int?
    init?(intValue: Int) {
        // we arent interested in numerics here but we might use them as a key
        // something like self.stringvalue = "\(intValue!)"
        return nil
    }
    
    var stringValue: String
    init?(stringValue: String)
    {
        self.stringValue = stringValue
    }
}

struct CurrencyRaw {
    
    enum RootKeys: String, CodingKey {
        case bpi, time
    }
    
    enum BPIKeys: String, CodingKey {
        case currPair = "EUR"
    }
    
    enum CurrPairKeys: String, CodingKey {
        case code, floatRate = "rate_float", desc = "description"
    }
    
    enum TimeKeys: String, CodingKey {
        case updatedISO
    }
    
    enum RealInfoKeys: String, CodingKey {
        case fullName = "full_name"
    }
    
    enum ReviewCountKeys: String, CodingKey {
        case count
    }
    
    let id: String
    let updatedAt: Date
    let dayDate: String
    let currencyDescription: String
    let currencyRate: Float
    
}

extension CurrencyRaw: Decodable {
    
    public init(from decoder: Decoder) throws {
        let responseContainer = try decoder.container(keyedBy: RootKeys.self)
        let bpiContainer = try responseContainer.nestedContainer(keyedBy: BPIKeys.self, forKey: .bpi)
        let currContainer = try bpiContainer.nestedContainer(keyedBy: CurrPairKeys.self, forKey: .currPair)
        let timeContainer = try responseContainer.nestedContainer(keyedBy: TimeKeys.self, forKey: .time)
        
        id = try currContainer.decode(String.self, forKey: .code)
        updatedAt = try timeContainer.decode(Date.self, forKey: .updatedISO)
        currencyDescription = try currContainer.decode(String.self, forKey: .desc)
        currencyRate = try currContainer.decode(Float.self, forKey: .floatRate)
        dayDate = DateHelpers.createDayDate(fromDate: updatedAt)
    }
    
    // internal init for testing
    internal init() {
        id = "Foo"
        updatedAt = Date()
        currencyDescription = "FooBar"
        currencyRate = 1234.1224
        dayDate = "2018-06-05"
    }
    
    init(rawBpi: BPIRaw.Bpi, idType: String = "EUR", descriptionString: String = "Euro") {
        id = idType
        currencyDescription = descriptionString
        currencyRate = rawBpi.floatValue
        dayDate = rawBpi.dateString
        updatedAt = rawBpi.updatedAt
    }
}


