//
//  CurrencyRaw.swift
//  n26
//
//  Created by Timothy Storey on 30/05/2018.
//  Copyright © 2018 BITE-Software. All rights reserved.
//

import Foundation

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
    let currencyDescription: String
    let currencyRate: Float
    
}

extension CurrencyRaw: Decodable {
    init(from decoder: Decoder) throws {
        
        let responseContainer = try decoder.container(keyedBy: RootKeys.self)
        let bpiContainer = try responseContainer.nestedContainer(keyedBy: BPIKeys.self, forKey: .bpi)
        let currContainer = try bpiContainer.nestedContainer(keyedBy: CurrPairKeys.self, forKey: .currPair)
        let timeContainer = try responseContainer.nestedContainer(keyedBy: TimeKeys.self, forKey: .time)
        
        id = try currContainer.decode(String.self, forKey: .code)
        updatedAt = try timeContainer.decode(Date.self, forKey: .updatedISO)
        currencyDescription = try currContainer.decode(String.self, forKey: .desc)
        currencyRate = try currContainer.decode(Float.self, forKey: .floatRate)
    }
}


