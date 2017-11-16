//
//  UIImage+Collage.swift
//  TodoFromBoxue
//
//  Created by roni on 2017/11/16.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    private func fixPictureSize(newSize: CGSize) -> CGRect {
        let radio = max(newSize.width / size.width, newSize.height / size.height)
        let width = size.width * radio
        let height = size.height * radio
        let scaleRect = CGRect(x: 0, y: 0, width: width, height: height)
        
        return scaleRect
    }
    
    func scale(to newSize: CGSize) -> UIImage {
        guard size != newSize else {
            return self
        }
        
        let scaleRect = fixPictureSize(newSize: newSize)
        
        UIGraphicsBeginImageContextWithOptions(scaleRect.size, false, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        draw(in: scaleRect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    static func collage(images: [UIImage], in size: CGSize) -> UIImage {
        let rows = images.count < 3 ? 1 : 2
        let columns = Int(round(Double(images.count) / Double(rows)))
        let memoSize = CGSize(width: round(size.width / CGFloat(columns)), height: round(size.height) / CGFloat(rows))
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        for (index, image) in images.enumerated() {
            let drawAtX = CGFloat(index % columns) * memoSize.width
            let drawAtY = CGFloat(index / columns) * memoSize.height
            
            image.scale(to: memoSize).draw(at: CGPoint(x: drawAtX, y: drawAtY))
        }
        
        let memoImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memoImage ?? UIImage()
    }
    
    static func isEqual(lhs: UIImage, rhs: UIImage) -> Bool {
        guard let data01 = UIImagePNGRepresentation(lhs), let data02 = UIImagePNGRepresentation(rhs) else {
            return false
        }
        
        return data01 == data02
    }
}
