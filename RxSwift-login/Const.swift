//
//  Const.swift
//  RxSwift-login
//
//  Created by 李永杰 on 2021/4/26.
//
// 几个用到的工具方法

import Foundation
import UIKit

// MARK: 十六进制字符串设置颜色, 示例HexColorAlpha("#2878FF")
public func HexColorAlpha(_ hexString: String, _ alpha: Float = 1) -> UIColor {
    return UIColor(hexString: hexString)!
}

public extension UIColor {
    convenience init?(hexString: String) {
        var chars = Array(hexString.hasPrefix("#") ? hexString.dropFirst() : hexString[...])
        let red, green, blue, alpha: CGFloat
        switch chars.count {
        case 3:
            chars = chars.flatMap { [$0, $0] }
            fallthrough
        case 6:
            chars = ["F","F"] + chars
            fallthrough
        case 8:
            alpha = CGFloat(strtoul(String(chars[0...1]), nil, 16)) / 255
            red   = CGFloat(strtoul(String(chars[2...3]), nil, 16)) / 255
            green = CGFloat(strtoul(String(chars[4...5]), nil, 16)) / 255
            blue  = CGFloat(strtoul(String(chars[6...7]), nil, 16)) / 255
        default:
            return nil
        }
        self.init(red: red, green: green, blue:  blue, alpha: alpha)
    }
}

public let kFontRegular = "PingFangSC-Regular"

// 常规字体
public func kFontRegularSize(_ iphone: CGFloat) -> UIFont {
    return UIFont(name: kFontRegular, size: iphone)!
}

public extension String {
    
    func widthWithFont(font : UIFont, fixedHeight : CGFloat) -> CGFloat {
        
        guard count > 0 && fixedHeight > 0 else {
            return 0
        }
        
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: fixedHeight), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size.width
    }
    
}
