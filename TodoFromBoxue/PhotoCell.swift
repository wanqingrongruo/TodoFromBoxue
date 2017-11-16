//
//  PhotoCell.swift
//  TodoFromBoxue
//
//  Created by roni on 2017/11/16.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RxSwift

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var checkmark: UIImageView!
    
    var representedAssetIdentifier: String!
    var isCheckmarked: Bool = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    func flipCheckmark() {
        self.isCheckmarked = !self.isCheckmarked
    }
    
    func selected() {
        self.flipCheckmark()
        setNeedsDisplay()
        
        UIView.animate(withDuration: 0.1) { [weak self] in
            if let isCheckmarked = self?.isCheckmarked {
                self?.checkmark.alpha = isCheckmarked ? 1 : 0
            }
        }
    }
}
