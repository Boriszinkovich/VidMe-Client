//
//  Extensions.swift
//  VidMeClient
//
//  Created by User on 13.08.17.
//  Copyright © 2017 BorisZinkovich. All rights reserved.
//

import UIKit

extension UIColor
{
    public class func getColorFromHexString (hex:String) -> UIColor
    {
        var cString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#"))
        {
            cString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 1))//cString.substringFromIndex(1)
        }
        
        if (cString.characters.count != 6)
        {
            return UIColor.gray
        }
        
        let rString = cString.substring(to: cString.index(cString.startIndex, offsetBy: 2))
        let gString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 2)).substring(to: cString.index(cString.startIndex, offsetBy: 2))
        let bString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 4)).substring(to: cString.index(cString.startIndex, offsetBy: 2))
        
        let r:UnsafeMutablePointer<UInt32> = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        let g:UnsafeMutablePointer<UInt32> = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        let b:UnsafeMutablePointer<UInt32> = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        Scanner(string: rString).scanHexInt32(r)
        Scanner(string: gString).scanHexInt32(g)
        Scanner(string: bString).scanHexInt32(b)
        print(CGFloat(r[0]))
        print(CGFloat(g[0]))
        print(CGFloat(b[0]))
        return UIColor(red: CGFloat(r[0]) / 255.0, green: CGFloat(g[0]) / 255.0, blue: CGFloat(b[0]) / 255.0, alpha: CGFloat(1))
    }
}






























