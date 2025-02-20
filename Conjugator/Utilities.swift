//
//  Utilities.swift
//  Conjugator
//
//  Created by A. Zheng (github.com/aheze) on 10/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension UIColor {
    var color: Color {
        return Color(self)
    }
}

extension Color {
    init(hex: Int, alpha: CGFloat = 1) {
        self.init(UIColor(hex: hex, alpha: alpha))
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1) {
        self.init(hex: UInt(hex), alpha: alpha)
    }

    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }

    var hex: UInt {
        return getHex() ?? 0x00AEEF
    }

    var hexString: String {
        return String(hex, radix: 16, uppercase: true)
    }

    /// from https://stackoverflow.com/a/28645384/14351818
    func getHex() -> UInt? {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0

        if getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            /// could be negative
            fRed = fRed.clamped(to: 0...1)
            fGreen = fGreen.clamped(to: 0...1)
            fBlue = fBlue.clamped(to: 0...1)

            let iRed = UInt(fRed * 255.0)
            let iGreen = UInt(fGreen * 255.0)
            let iBlue = UInt(fBlue * 255.0)

            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let hex = (iRed << 16) + (iGreen << 8) + iBlue
            return hex
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}

/// from https://stackoverflow.com/a/46729248/14351818
extension UIColor {
    func toColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage = max(min(percentage, 1), 0)
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }

            return UIColor(
                red: CGFloat(r1 + (r2 - r1) * percentage),
                green: CGFloat(g1 + (g2 - g1) * percentage),
                blue: CGFloat(b1 + (b2 - b1) * percentage),
                alpha: CGFloat(a1 + (a2 - a1) * percentage)
            )
        }
    }
}

/// get gradient color for search bar field
extension UIColor {
    var rgb: (r: CGFloat, g: CGFloat, b: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r: r, g: g, b: b)
        } else {
            return (0, 0, 0)
        }
    }

    var hsba: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h: h, s: s, b: b, a: a)
    }

    /// get a gradient color
    func offset(by offset: CGFloat) -> UIColor {
        let (h, s, b, a) = hsba
        var newHue = h - offset

        /// make it go back to positive
        while newHue <= 0 {
            newHue += 1
        }
        let normalizedHue = newHue.truncatingRemainder(dividingBy: 1)
        return UIColor(hue: normalizedHue, saturation: s, brightness: b, alpha: a)
    }

    /// darken or lighten
    func adjust(by offset: CGFloat) -> UIColor {
        let (r, g, b) = rgb
        let newR = r + offset
        let newG = g + offset
        let newB = b + offset

        return UIColor(red: newR, green: newG, blue: newB, alpha: 1)
    }
}

extension Comparable {
    /// used for the UIColor
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension UIColor {
    /// make a color more visible
    func getTextColor(backgroundIsDark: Bool, threshold: CGFloat? = nil) -> UIColor {
        let isLight = isLight(threshold: threshold)
        if isLight, !backgroundIsDark {
            let adjustedTextColor = toColor(.black, percentage: 0.6)
            return adjustedTextColor
        } else if !isLight, backgroundIsDark {
            let adjustedTextColor = toColor(.white, percentage: 0.8)
            return adjustedTextColor
        } else {
            return self
        }
    }

    func isLight(threshold: CGFloat?) -> Bool {
        let threshold = threshold ?? CGFloat(0.55)
        let (r, g, b) = rgb
        let brightness = CGFloat(
            ((r * 299) + (g * 587) + (b * 114)) / 1000
        )
        return (brightness > threshold)
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

/// From https://gist.github.com/IanKeen/4d29b48519dca125b21675eeb7623d60
import SwiftUI
@propertyWrapper
struct Storage<T: AppStorageConvertible>: RawRepresentable {
    var rawValue: String { wrappedValue.storedValue }
    var wrappedValue: T

    init?(rawValue: String) {
        guard let value = T(rawValue) else { return nil }
        self.wrappedValue = value
    }

    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

extension Binding {
    func binding<T>() -> Binding<T> where Value == Storage<T> {
        return .init(
            get: { wrappedValue.wrappedValue },
            set: { value, transaction in
                self.transaction(transaction).wrappedValue.wrappedValue = value
            }
        )
    }
}

protocol AppStorageConvertible {
    init?(_ storedValue: String)
    var storedValue: String { get }
}

extension RawRepresentable where RawValue: LosslessStringConvertible, Self: AppStorageConvertible {
    init?(_ storedValue: String) {
        guard let value = RawValue(storedValue) else { return nil }
        self.init(rawValue: value)
    }

    var storedValue: String {
        String(describing: rawValue)
    }
}

extension Array: AppStorageConvertible where Element: LosslessStringConvertible {
    public init?(_ storedValue: String) {
        let values = storedValue.components(separatedBy: ",")
        self = values.compactMap(Element.init)
    }

    var storedValue: String {
        return map(\.description).joined(separator: ",")
    }
}
