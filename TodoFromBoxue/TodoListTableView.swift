//
//  TodoListTableView.swift
//  TodoFromBoxue
//
//  Created by roni on 2017/11/9.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit

extension TodoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let todo = todoItems.value[indexPath.row]
            todo.toggleFinished()
            
            todoItems.value[indexPath.row] = todo
            
            configureStatus(for: cell, with: todo)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        todoItems.value.remove(at: indexPath.row)
    }
}

extension TodoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItem", for: indexPath)
        let todo = todoItems.value[indexPath.row]
        
        configureStatus(for: cell, with: todo)
        configureLabel(for: cell, with: todo)
        
        return cell
    }
}
