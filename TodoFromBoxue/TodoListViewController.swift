//
//  TodoListViewController.swift
//  TodoFromBoxue
//
//  Created by roni on 2017/11/9.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RxSwift

class TodoListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTo: UIBarButtonItem!
    @IBOutlet weak var clearTodoBtn: UIButton!
    
    let todoItems = Variable<[TodoItem]>([])
    let bag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadTodoItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        todoItems.asObservable().subscribe(onNext: { [weak self] todos in
            self?.updateUI(todos: todos)
        }).disposed(by: bag)
    }
    
    func updateUI(todos: [TodoItem]) {
        clearTodoBtn.isEnabled = !todos.isEmpty
        
        addTo.isEnabled = todos.filter{ !$0.isFinished }.count < 5
        title = todos.isEmpty ? "Todo" : "\(todos.count) ToDOs"
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTodoItem(_ sender: Any) {
        
        let todoItem = TodoItem(name: "Todo Demo", isFinished: false)
        todoItems.value.append(todoItem)
    }
    
    @IBAction func saveTodoList(_ sender: Any) {
        saveTodoItems()
    }
    
    @IBAction func clearTodoList(_ sender: Any) {
        todoItems.value.removeAll()
    }
    
    
}
