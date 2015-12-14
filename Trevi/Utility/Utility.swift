//
//  Utility.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public typealias CallBack = ( Request, Response ) -> Bool // will remove next

public enum HTTPMethodType: String {
    case GET       = "GET"
    case POST      = "POST"
    case PUT       = "PUT"
    case HEAD      = "HEAD"
    case UNDEFINED = "UNDEFINED"
}
extension NSDate {
    struct Date {
        static let formatter = NSDateFormatter()
    }
    var formatted: String {
        Date.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
        Date.formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        Date.formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        Date.formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return Date.formatter.stringFromDate(self)
    }
}
public enum HTTPMethod {
    case Get( CallBack )
    case Post( CallBack )
    case Put( CallBack )
    case Delte( CallBack )
}