//
//  PhotoCollectionViewController.swift
//  TodoFromBoxue
//
//  Created by roni on 2017/11/16.
//  Copyright © 2017年 roni. All rights reserved.
//

import UIKit
import Photos
import RxSwift


class PhotoCollectionViewController: UICollectionViewController {
    
    fileprivate let selectedPhotosSubject = PublishSubject<UIImage>()
    var selectedPhotos: Observable<UIImage> {
        return selectedPhotosSubject.asObservable()
    }
    
    let bag = DisposeBag()
    
    fileprivate lazy var photos = PhotoCollectionViewController.loadPhotos()
    fileprivate lazy var imageManager = PHCachingImageManager()
    
    fileprivate lazy var thumbnailsize: CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        
        return CGSize(width: cellSize.width * UIScreen.main.scale, height: cellSize.height * UIScreen.main.scale)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCellSpace()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        selectedPhotosSubject.onCompleted()
    }
    
    func setCellSpace() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: (width-40) / 4, height: (width-40) / 4)
        collectionView!.collectionViewLayout = layout
    }
    
    func authorize(_ status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(), completion: @escaping (_ authorized: Bool) -> Void) {
        switch status {
        case .authorized:
            // We are authorized. Run block
            completion(true)
            
            // 重新获取数据源
            self.photos = PhotoCollectionViewController.loadPhotos()
            self.collectionView?.reloadData()
        case .notDetermined:
            // Ask user for permission
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.authorize(status,completion: completion)
                })
            })
        default: ()
        DispatchQueue.main.async(execute: { () -> Void in
            completion(false)
        })
        }
    }
    
    open override func loadView() {
        super.loadView()
        
        // TODO: Settings
        view.backgroundColor = UIColor.white
        
        // Make sure we really are authorized
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.collectionView?.reloadData()
        }
    }
}

extension PhotoCollectionViewController {
    
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: options)
    }
}

extension PhotoCollectionViewController {
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoMemo", for: indexPath) as! PhotoCell
        
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: thumbnailsize, contentMode: .aspectFill, options: nil) { (image, _) in
            guard let image = image else{
                return
            }
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.imageView.image = image
            }
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            cell.selected()
        }
        
        imageManager.requestImage(for: asset,
                                  targetSize: view.frame.size,
                                  contentMode: .aspectFill,
                                  options: nil,
                                  resultHandler: { [weak self] (image, info) in
                                    guard let image = image, let info = info else { return }
                                    
                                    if let isThumbnail = info[PHImageResultIsDegradedKey] as? Bool,
                                        !isThumbnail {
                                        
                                        // TODO: Trigger photo selection event here
                                        self?.selectedPhotosSubject.onNext(image)
                                    }
        })
    }
    
}
