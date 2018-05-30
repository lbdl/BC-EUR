//
//  Mapped.swift
//  AirTasker
//
//  Created by Timothy Storey on 23/01/2018.
//  Copyright © 2018 BITE-Software. All rights reserved.
//

import Foundation

/// An enum with associated values to be used by the
/// JSONMappingProtocol as a retur type that can encapsulate
/// any decoding errors or the decoded type held in generic type A
enum Mapped<A> {
    case MappingError(Error)
    case Value(A)
    
    func associatedValue() -> Any {
        switch self {
        case .MappingError(let value):
            return value
        case .Value(let value):
            return value
        }
    }
}
