//
//  AssetListVC.swift
//  PhotoPickerStarter
//
//  Created by yanghongyan on 15/1/15.
//  Copyright (c) 2015年 yanghongyan. All rights reserved.
//

import UIKit

import Photos


class AssetListVC: UICollectionViewController {
    
    var fetchResults: PHFetchResult?
    var selectedAssets:[PHAsset]=[]
    
    private var thumbnailSize = CGSizeZero
    
    private let imageManager: PHCachingImageManager =
    PHCachingImageManager()
    
    private var cachingIndexes: [NSIndexPath] = []
    private var lastCacheFrameCenter: CGFloat = 0
    private var cacheQueue =
    dispatch_queue_create("cache_queue", DISPATCH_QUEUE_SERIAL)
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        dispatch_async(cacheQueue) {
            self.updateCache()
        }
    }
    func assetsAtIndexPaths(indexPaths:[NSIndexPath]) -> [PHAsset] {
        return indexPaths.map { indexPath in
            return self.currentAssetAtIndex(indexPath.item)
        }
    }
    func resetCache() {
        imageManager.stopCachingImagesForAllAssets()
        cachingIndexes.removeAll(keepCapacity: true)
        lastCacheFrameCenter = 0
    }
    func updateCache() {
        let currentFrameCenter = CGRectGetMidY(collectionView!.bounds)
        if abs(currentFrameCenter - lastCacheFrameCenter) <
            CGRectGetHeight(collectionView!.bounds) / 3 {
                return
        }
        lastCacheFrameCenter = currentFrameCenter
        let maxCachedAssets = 60
        
        var visibleIndexes = collectionView!.indexPathsForVisibleItems()
            as [NSIndexPath]
        visibleIndexes.sort { a, b in
            a.item < b.item
        }
        if visibleIndexes.count == 0 {
            return
        }
        
        var totalItemCount = selectedAssets.count
        if fetchResults != nil {
            totalItemCount = fetchResults!.count
        }
        let lastItemToCache = min(totalItemCount,visibleIndexes[visibleIndexes.count-1].item + maxCachedAssets/2)
        let firstItemToCache = max(0, visibleIndexes[0].item - maxCachedAssets/2)
        
        let options = PHImageRequestOptions()
        options.networkAccessAllowed = true
        options.resizeMode = .Fast
        
        // 1
        var indexesToStopCaching: [NSIndexPath] = []
        cachingIndexes = cachingIndexes.filter { index in
            if index.item < firstItemToCache || index.item > lastItemToCache {
                indexesToStopCaching.append(index)
                return false
            }
            return true
        }
        // 2
        imageManager.stopCachingImagesForAssets(assetsAtIndexPaths(indexesToStopCaching),
            targetSize: thumbnailSize,
            contentMode: .AspectFill,
            options: options)
        
        // 1
        var indexesToStartCaching: [NSIndexPath] = []
        for i in firstItemToCache..<lastItemToCache {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            if !contains(cachingIndexes, indexPath) {
                indexesToStartCaching.append(indexPath)
            }
        }
        cachingIndexes += indexesToStartCaching
        // 2
        imageManager.startCachingImagesForAssets(
            assetsAtIndexPaths(indexesToStartCaching),
            targetSize: thumbnailSize, contentMode: .AspectFill,
            options: options)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.allowsMultipleSelection = true
        resetCache()
    }

    override func viewWillAppear(animated: Bool)  {
        super.viewWillAppear(animated)
        
        // Calculate Thumbnail Size
        let scale = UIScreen.mainScreen().scale
        let cellSize = (collectionViewLayout as UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
        collectionView!.reloadData()
        updateSelectedItems()
        resetCache()
    }
    func updateSelectedItems() {
        // Select the selected items
    }
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        collectionView!.reloadData()
        updateSelectedItems()
    }
    func currentAssetAtIndex(index:NSInteger) -> PHAsset {
        if let fetchResult = fetchResults {
            return fetchResult[index] as PHAsset
        } else {
            return selectedAssets[index]
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)  {
        // Update selected Assets
    }
    
    override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath)  {
        // Update selected Assets
    }
    
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fetchResult = fetchResults {
            return fetchResult.count
        } else{
            return selectedAssets.count
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("idCell", forIndexPath: indexPath) as AssetListCell
        
        // Populate Cell
        // 1
        let reuseCount = ++cell.reuseCount
        let asset = currentAssetAtIndex(indexPath.item)
        // 2
        let options = PHImageRequestOptions()
        options.networkAccessAllowed = true
        options.resizeMode = .Fast
        // 3
        imageManager.requestImageForAsset(asset,
            targetSize: thumbnailSize,
            contentMode: .AspectFill, options: options)
            { result, info in
                if reuseCount == cell.reuseCount {
                    cell.imageView.image = result
                }
        }

        
        return cell
    }
}
