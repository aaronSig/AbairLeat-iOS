//
//  NSDate-Extenstions.swift
//  Abair Leat
//
//  Created by Aaron Signorelli on 30/11/2015.
//  Copyright © 2015 Superpixel. All rights reserved.
//

import Foundation

extension NSDate {
    struct Date {
        static let formatter = NSDateFormatter()
    }
    
    static func fromIsoDate(isoDate: String) -> NSDate? {
        Date.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
        Date.formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        Date.formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        Date.formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return Date.formatter.dateFromString(isoDate)
    }
    
    func toIsoFormat() -> String {
        Date.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
        Date.formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        Date.formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        Date.formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return Date.formatter.stringFromDate(self)
    }
    
    func toShortDateStyle() -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        return formatter.stringFromDate(self)
    }
    
    func toShortTimeStyle() -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.NoStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return formatter.stringFromDate(self)
    }

    // returns true if the date happened today
    func occuredToday() -> Bool {
        return numberOfDaysUntilDateTime(NSDate()) < 1
     }
    
    func numberOfDaysUntilDateTime(toDateTime: NSDate, inTimeZone timeZone: NSTimeZone? = nil) -> Int {
        let calendar = NSCalendar.currentCalendar()
        if let timeZone = timeZone {
            calendar.timeZone = timeZone
        }
        
        var fromDate: NSDate?, toDate: NSDate?
        
        calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: self)
        calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: toDateTime)
        
        let difference = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: [])
        return difference.day
    }
}
