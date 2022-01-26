//
//  DateConverter.swift
//  FinalProject_MADTPEEPS_iOS
//
//  Created by Surabhi Rupani on 2022-01-26.
//

import Foundation

extension Date {
    func toFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "en_US")
        
        formatter.dateFormat = "EEE, dd MMM yyyy"
        let dateString = formatter.string(from: self)
        
        formatter.dateFormat = "hh:mm a"
        let timeString = formatter.string(from: self)
        
        let orderDateString = "\(dateString) at \(timeString)"
        return orderDateString
    }
}
