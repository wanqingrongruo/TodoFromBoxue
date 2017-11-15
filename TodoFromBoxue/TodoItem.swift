//
//  TodoItem.swift
//  TodoFromBoxue
//
//  Created by roni on 2017/11/9.
//  Copyright © 2017年 roni. All rights reserved.
//

import Foundation

class TodoItem: NSObject, NSCoding {
    var name: String = ""
    var isFinished: Bool = false
    
    init(name: String, isFinished: Bool) {
        self.name = name
        self.isFinished = isFinished
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        isFinished = aDecoder.decodeBool(forKey: "isFinished")
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(isFinished, forKey: "isFinished")
    }
    
    func toggleFinished() {
        isFinished = !isFinished
    }
}
