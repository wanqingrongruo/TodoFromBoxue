//
//  PlistDocument.swift
//  TodoFromBoxue
//
//  Created by roni on 2017/11/15.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation
import UIKit

class PlistDocument: UIDocument {
    
    var plistData: NSData!
    
    init(fileURL: URL, data: NSData) {
        super.init(fileURL: fileURL)
        
        self.plistData = data
    }
    
    override func contents(forType typeName: String) throws -> Any {
        return plistData
    }
    
    override func load(fromContents contents: Any,
                       ofType typeName: String?) throws {
        if let userContent = contents as? NSData {
            plistData = userContent
        }
    }
}
