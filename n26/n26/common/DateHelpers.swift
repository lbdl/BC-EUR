//
//  DateHelpers.swift
//  n26
//
//  Created by Timothy Storey on 05/06/2018.
//  Copyright © 2018 BITE-Software. All rights reserved.
//

import Foundation

class DateHelpers:NSObject {

static var dateFormatter: DateFormatter = DateFormatter()
    
static var formatString: String = "yyyy-MM-dd"

static func createDayDate(fromDate: Date) -> String {
        dateFormatter.dateFormat = formatString
        return dateFormatter.string(from: fromDate)
    }
}
