//
//  TodoListViewConfigure.swift
//  TodoFromBoxue
//
//  Created by roni on 2017/11/9.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RxSwift

let CELL_CHECKMARK_TAG = 1001
let CELL_TODO_TITLE_TAG = 1002

enum SaveTodoError: Error {
    case cannotSaveToLocalFile
    case iCloudIsNotEnabled
    case cannotReadLocalFile
    case cannotCreateFileOnCloud
}

extension TodoListViewController {
    
    func configureStatus(for cell: UITableViewCell, with item: TodoItem) {
        let label = cell.viewWithTag(CELL_CHECKMARK_TAG) as! UILabel
        
        if item.isFinished {
            label.text = "✓"
        }else{
            label.text = ""
        }
    }
    
    func configureLabel(for cell: UITableViewCell, with item: TodoItem) {
        let label = cell.viewWithTag(CELL_TODO_TITLE_TAG) as! UILabel
        
        label.text = item.name
    }
    
    // 目录
    func documentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    // 完整路径
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("TodoLsit.plist")
    }
    
    // 解压缩
    func loadTodoItems() {
        let path = dataFilePath()
        
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            todoItems.value = unarchiver.decodeObject(forKey: "TodoItems") as! [TodoItem]
            
            unarchiver.finishDecoding()
        }
    }
    
    // 压缩
    func saveTodoItems() -> Observable<Void>{
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        
        archiver.encode(todoItems.value, forKey: "TodoItems")
        archiver.finishEncoding()
        
      //  data.write(to: dataFilePath(), atomically: true)
        
        return Observable.create({ observer in
            let result = data.write(to: self.dataFilePath(), atomically: true)
            if !result {
                observer.onError(SaveTodoError.cannotSaveToLocalFile)
            }else{
                observer.onCompleted()
            }
            
            return Disposables.create()
        })
    }
    
    //
    
    func ubiquityURL(_ filename: String) -> URL? {
        let ubiquityURL =
            FileManager.default.url(forUbiquityContainerIdentifier: nil)
        
        if ubiquityURL != nil {
            return ubiquityURL!.appendingPathComponent(filename)
        }
        
        return nil
    }
    
    // 同步到 icloud
    func syncTodoToCloud() -> Observable<URL> {
        
        return Observable.create({ observer in
            guard let cloudUrl = self.ubiquityURL("Documents/TodoList.plist") else {
                observer.onError(SaveTodoError.iCloudIsNotEnabled)
                return Disposables.create()
            }
            
            guard let localData = NSData(contentsOf: self.dataFilePath()) else {
                observer.onError(SaveTodoError.cannotReadLocalFile)
                return Disposables.create()
            }
            
            let plist = PlistDocument(fileURL: cloudUrl, data: localData)
            
            plist.save(to: cloudUrl, for: .forOverwriting, completionHandler: {
                (success: Bool) -> Void in
                
                if success {
                    observer.onNext(cloudUrl)
                    observer.onCompleted()
                } else {
                    observer.onError(SaveTodoError.cannotCreateFileOnCloud)
                }
            })
            
            return Disposables.create()
        })
    }
}
