//
//  TodoDetailViewController.swift
//  TodoFromBoxue
//
//  Created by roni on 2017/11/15.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import RxSwift

class TodoDetailViewController: UITableViewController {
    
    fileprivate let todoSubject = PublishSubject<TodoItem>()
    var todo: Observable<TodoItem> {
        return todoSubject.asObservable()
    }
    var todoItem: TodoItem!
    
    var bag = DisposeBag()
    
    fileprivate let images = Variable<[UIImage]>([])
    fileprivate var todoCollage: UIImage?
    
    @IBOutlet weak var todoName: UITextField!
    @IBOutlet weak var isFinished: UISwitch!
    @IBOutlet weak var doneBarBtn: UIBarButtonItem!
    @IBOutlet weak var memoCollageBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        images.asObservable().subscribe(onNext: {
            [weak self] images in
            guard let `self` = self else { return }
            guard !images.isEmpty else {
                self.resetMemoBtn()
                return
            }
            
            /// 1. Merge photos
            self.todoCollage = UIImage.collage(images: images, in: self.memoCollageBtn.frame.size)
            /// 2. Set the merged photo as the background image of the button
            self.setMemoBtn(bkImage: self.todoCollage ?? UIImage())
        }).addDisposableTo(bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        todoName.becomeFirstResponder()
        
        
        if let todoItem = todoItem {
            self.todoName.text = todoItem.name
            self.isFinished.isOn = todoItem.isFinished
            
            if todoItem.pictureMemoFilename != "" {
                let url = getDocumentsDir().appendingPathComponent(todoItem.pictureMemoFilename)
                if let data = try? Data(contentsOf: url) {
                    self.memoCollageBtn.setBackgroundImage(UIImage(data: data), for: .normal)
                    self.memoCollageBtn.setTitle("", for: .normal)
                }
            }
            
            doneBarBtn.isEnabled = true
        }else{
            todoItem = TodoItem()
        }
        
        print("Resource tracing: \(RxSwift.Resources.total)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        todoSubject.onCompleted()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        todoItem.name = todoName.text!
        todoItem.isFinished = isFinished.isOn
        todoItem.pictureMemoFilename = savePictureMemos()
        
        todoSubject.onNext(todoItem)
        todoSubject.onCompleted()
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let photoCollectionViewController = segue.destination as! PhotoCollectionViewController
        
        // 请求权限
        photoCollectionViewController.authorize { (authorized) in
            guard authorized == true else {
                return
            }
        }
        
        self.images.value.removeAll()
        self.resetMemoBtn()
        
        let selectedPhotos = photoCollectionViewController.selectedPhotos
        _ = selectedPhotos.subscribe(onNext: { (image) in
            self.images.value.append(image)
        }, onError: nil, onCompleted: nil) {
            print("Finished choosing photo memos")
        }
        
    }
    
}

extension TodoDetailViewController {
    fileprivate func getDocumentsDir() -> URL {
        return FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask)[0]
    }
    
    fileprivate func resetMemoBtn() {
        // Todo: Reset the add picture memo btn style
        memoCollageBtn.setBackgroundImage(nil, for: .normal)
        memoCollageBtn.setTitle("Tap here to add your picture memos.", for: .normal)
    }
    
    fileprivate func setMemoBtn(bkImage: UIImage) {
        // Todo: Set the background and title of add picture memo btn
        memoCollageBtn.setBackgroundImage(bkImage, for: .normal)
        memoCollageBtn.setTitle("", for: .normal)
    }
    
    fileprivate func savePictureMemos() -> String {
        // Todo: Save the picture memos preview as a png
        // file and return its file name.
        
        if let todoCollage = self.todoCollage,
            let data = UIImagePNGRepresentation(todoCollage) {
            let path = getDocumentsDir()
            let filename = self.todoName.text! + UUID().uuidString + ".png"
            let memoImageUrl = path.appendingPathComponent(filename)
            
            try? data.write(to: memoImageUrl)
            
            return filename
        }
        
        return self.todoItem.pictureMemoFilename
    }
}

extension TodoDetailViewController {
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func setMemoSectionHederText() {
        // Todo: Set section header to the number of
        // pictures selected.
    }
}


extension TodoDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneBarBtn.isEnabled = newText.length > 0
        
        return true
    }
}

extension UITableView {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        // 放弃焦点
        if let v = view ,(v.isKind(of: UITextField.self) || v.isKind(of: UITextView.self)){
            return v
        }
        self.endEditing(true)
        
        return view
    }
}
