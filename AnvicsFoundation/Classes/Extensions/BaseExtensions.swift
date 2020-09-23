//
//  BaseExtensions.swift
//  Cazila
//
//  Created by Nikita Arkhipov on 13/11/2018.
//  Copyright © 2018 Nikita Arkhipov. All rights reserved.
//

import UIKit

public extension NSString{
    func size(withFont font: UIFont, maxWidth: CGFloat? = nil) -> CGSize {
        let rect = boundingRect(with: CGSize(width: maxWidth ?? 0, height: 0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size
    }
}

public extension String{
    func size(withFont font: UIFont, maxWidth: CGFloat? = nil) -> CGSize {
        return (self as NSString).size(withFont: font, maxWidth: maxWidth)
    }
    /**
     Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
     
     - Parameter length: A `String`.
     - Parameter trailing: A `String` that will be appended after the truncation.
     
     - Returns: A `String` object.
     */
    func truncate(length: Int, trailing: String = "…") -> String {
        if count > length {
            return String(prefix(length)) + trailing
        } else {
            return self
        }
    }

    func byRemoving(characters: [String]) -> String{
        var st = self
        for ch in characters{
            st = st.replacingOccurrences(of: ch, with: "")
        }
        return st
    }
}

public extension Comparable{
    func bound(min: Self, max: Self) -> Self{
        precondition(min < max)
        if self < min { return min }
        if self > max { return max }
        return self
    }
}

public extension Int {
    func minutesToString() -> String{
        let m = self % 60
        let ms = m < 10 ? "0\(m)" : "\(m)"
        return "\(self / 60)h \(ms)m"
    }

    var signedString: String{
        self > 0 ? "+\(self)" : "\(self)"
    }
}

public extension Array{
    func safeAt(index: Int) -> Element?{
        if index < 0 || index >= count { return nil }
        return self[index]
    }
}

public extension Date{
    func string(format: String, locale: Locale = Locale(identifier: "ru_RU")) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = locale
        return dateFormatter.string(from: self)
    }

    func dayAndWeekDayFormatted() -> String{
        return string(format: "MMM d, E", locale: Locale(identifier: "ru_RU"))
    }
}

public func GCD_After(_ seconds: Double, perform: @escaping () -> ()){
    let delayTime = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
        perform()
    }
}

public func GCD_Main(perform: @escaping () -> ()){
    DispatchQueue.main.async(execute: perform)
}

public func GCD_Background(perform: @escaping () -> ()){
    DispatchQueue.global().async(execute: perform)
}


public typealias EmptyBlock = () -> ()

public extension Array where Element == String {
    func joined(separator: String, lastSeparator: String) -> String{
        if count < 2 { return joined(separator: separator) }
        var a = self
        let last = a.removeLast()
        return a.joined(separator: separator) + lastSeparator + last
    }
}

infix operator >>

public func >><T, U>(left: T?, right: (T) -> U) -> U?{
    if let l = left { return right(l) }
    return nil
}
