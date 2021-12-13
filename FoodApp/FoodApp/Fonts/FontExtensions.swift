//
//  FontExtensions.swift
//  FoodApp
//
//  Created by Nikolaos Mikrogeorgiou on 25/11/21.
//

import Foundation
import UIKit

// MARK: Fonts used for faster typing

extension UIFont {
    static func robotoRegular(size: CGFloat) -> UIFont? {
        return UIFont(name: "Roboto-Regular", size: size)
    }
}

extension UIFont {
    static func robotoBold(size: CGFloat) -> UIFont? {
        return UIFont(name: "Roboto-Bold", size: size)
    }
}

extension UIFont {
    static func montserratBold(size: CGFloat) -> UIFont? {
        return UIFont(name: "Montserrat-Bold", size: size)
    }
}

extension UIFont {
    static func montserratRegular(size: CGFloat) -> UIFont? {
        return UIFont(name: "Montserrat-Regular", size: size)
    }
}

extension UIFont {
    static func montserratLight(size: CGFloat) -> UIFont? {
        return UIFont(name: "Montserrat-Light", size: size)
    }
}

extension UIFont {
    static func montserratMedium(size: CGFloat) -> UIFont? {
        return UIFont(name: "Montserrat-Medium", size: size)
    }
}

extension UIFont {
    static func montserratSemiBold(size: CGFloat) -> UIFont? {
        return UIFont(name: "Montserrat-SemiBold", size: size)
    }
}
