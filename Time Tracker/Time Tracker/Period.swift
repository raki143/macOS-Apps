//
//  Period.swift
//  Time Tracker
//
//  Created by Rakesh Kumar on 01/11/19.
//  Copyright © 2019 Rakesh Kumar. All rights reserved.
//

import Cocoa

extension Period {
    func currentlyString() -> String {
        if let inDate = self.inDate {
            return Period.stringFromDates(date1: inDate, date2: Date())
        }
        return "Error 1"
    }
    
   class func stringFromDates(date1:Date,date2:Date) -> String {
        var theString = ""
        let cal = Calendar.current.dateComponents([.hour,.minute,.second], from: date1, to: date2)
        
        guard let hour = cal.hour, let minute = cal.minute, let second = cal.second else {
            return "Error 2"
        }
        
        if hour > 0 {
            theString += "\(hour)h \(minute)m "
        }else {
            if minute > 0 {
                theString += "\(minute)m "
            }
        }
        theString += "\(second)s"
        
        return theString
    }
    
    func prettyDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        return formatter.string(from: date)
    }
    
    func prettyInDate() -> String {
        if let inDate = self.inDate {
            return prettyDate(date: inDate)
        }
        return "Error 3"
    }
    
    func prettyOutDate() -> String {
           if let outDate = self.outDate {
               return prettyDate(date: outDate)
           }
           return "Error 4"
    }
    
    func time() -> TimeInterval {
        if let inDate = self.inDate {
            if let outDate = self.outDate {
                return outDate.timeIntervalSince(inDate)
            }else {
                return Date().timeIntervalSince(inDate)
            }
        }
        return 0.0
    }
}
