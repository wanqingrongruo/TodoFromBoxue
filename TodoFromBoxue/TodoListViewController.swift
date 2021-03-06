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
        
//        let todoItem = TodoItem(name: "Todo Demo", isFinished: false)
//        todoItems.value.append(todoItem)
    }
    
    @IBAction func saveTodoList(_ sender: Any) {
        
        // 如果一个Controller会常驻在内存里不会释放，我们就不要把这种单次事件的订阅对象放到它的DisposeBag里。实际上，对于这种单次的事件序列，我们可以在订阅之后不做任何事情 -- 
        _ = saveTodoItems().subscribe(onNext: nil, onError: { [weak self](error) in
            self?.flash(title: "Error",
                        message: error.localizedDescription)
            }, onCompleted: { [weak self] in
                self?.flash(title: "Success",
                            message: "All Todos are saved on your phone.")
        }, onDisposed: { print("SaveOb disposed") }
        )
        
        print("RC: \(RxSwift.Resources.total)")
    }
    
    @IBAction func clearTodoList(_ sender: Any) {
        todoItems.value.removeAll()
      }
    
    @IBAction func syncToCloud(_ sender: Any) {
        // Add sync code here
        _ = syncTodoToCloud().subscribe(
            onNext: {
                self.flash(title: "Success",
                           message: "All todos are synced to: \($0)")
        },
            onError: {
                self.flash(title: "Failed",
                           message: "Sync failed due to: \($0.localizedDescription)")
        },
            onDisposed: {
                print("SyncOb disposed")
        }
        )
        
        print("RC: \(RxSwift.Resources.total)")
    }
    
    
}

extension TodoListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let todoDetailViewController = navigationController.topViewController as! TodoDetailViewController
        
        if segue.identifier == "AddTodo" {
            todoDetailViewController.title = "Add Todo"
            
            _ = todoDetailViewController.todo.subscribe(onNext: { [weak self](newTodo) in
                self?.todoItems.value.append(newTodo)
                }, onDisposed: {
                    print("Finish adding a new todo.")
            })
        }else if segue.identifier == "EditTodo" {
            todoDetailViewController.title = "Edit Todo"
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                todoDetailViewController.todoItem = todoItems.value[indexPath.row]
                
                _ = todoDetailViewController.todo.subscribe(onNext: { [weak self](todo) in
                    self?.todoItems.value[indexPath.row] = todo
                    }, onError: nil, onCompleted: nil, onDisposed: {
                        print("Finish adding a new todo.")
                })
            }
            
        }
    }
}
