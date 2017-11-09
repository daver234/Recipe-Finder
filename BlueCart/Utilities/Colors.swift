//
//  Colors.swift
//  BlueCart
//
//  Created by David Rothschild on 11/6/17.
//  Copyright © 2017 Dave Rothschild. All rights reserved.
//

import UIKit

/// Colors used in this app
struct ColorPalette {
    struct Blue {
        static let Dark = UIColor(netHex: 0x3050A8)
        let exampleDark = #colorLiteral(red: 0.1882352941, green: 0.3137254902, blue: 0.6588235294, alpha: 1)
        static let Medium = UIColor(netHex: 0x00549F)
        let exampleMedium = #colorLiteral(red: 0, green: 0.3294117647, blue: 0.6235294118, alpha: 1)
        static let Light = UIColor(netHex: 0x007AC9)
        let exampleLight = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.7882352941, alpha: 1)
    }
    
    struct Green {
        static let Medium = UIColor(netHex: 0x5B8F22)
        let exampleMedium = #colorLiteral(red: 0.3568627451, green: 0.5607843137, blue: 0.1333333333, alpha: 1)
        static let Light = UIColor(netHex: 0x95D26B)
        let exampleLight = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
    }
    
    struct Orange {
        static let Medium = UIColor(netHex: 0xF2AF00)
        let example = #colorLiteral(red: 0.9490196078, green: 0.6862745098, blue: 0, alpha: 1)
    }
    
    struct Grey {
        static let Medium = UIColor(netHex: 0xC6C6C6)
        let example = #colorLiteral(red: 0.7764705882, green: 0.7764705882, blue: 0.7764705882, alpha: 1)
    }
    
    struct White {
        static let Medium = UIColor(netHex: 0xFFFFFF)
        let example = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    struct Red {
        static let Medium = UIColor(netHex: 0xBE2813)
        let example = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    }
    
    struct Black {
        static let Medium = UIColor(netHex: 0x000000)
        let example = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex: Int) {
        self.init(red: (netHex >> 16) & 0xff, green: (netHex >> 8) & 0xff, blue: netHex & 0xff)
    }
}
