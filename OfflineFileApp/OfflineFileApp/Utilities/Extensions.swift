//
//  Extensions.swift
//  OfflineFileApp
//
//  Created by VC on 05/04/24.
//

import Foundation
import UIKit


extension UIColor {
    static func colorFromString(_ colorString: String) -> UIColor? {
        switch colorString.lowercased() {
        case "black":
            return UIColor.black
        case "red":
            return UIColor.red
        case "yellow":
            return UIColor.yellow
        case "green":
            return UIColor.green
        case "blue":
            return UIColor.blue
        case "brown":
            return UIColor.brown
        case "purple":
            return UIColor.purple
        case "orange":
            return UIColor.orange
        default:
            return nil
        }
    }
}




