//
//  SurahCollectionView.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 19/4/23.
//

import UIKit

class SurahCollectionView: UICollectionView {
    var chapter: Chapter!{
        didSet{
            self.delegate = self
            self.dataSource = self
            self.prefetchDataSource = self
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.register(UINib(nibName: SurahCollectionViewCell.reuseIdentifier, bundle:.main), forCellWithReuseIdentifier: SurahCollectionViewCell.reuseIdentifier)
    }
    
    let loadingQueue = OperationQueue()
    var loadingOperations: [IndexPath: VerseDataLoaderOperation] = [:]
    
    func determineCellHeight(for verse: Verse) -> CGFloat{
        return 100
    }
    
}

extension SurahCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chapter.getVersesCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SurahCollectionViewCell.reuseIdentifier, for: indexPath)
        cell.backgroundColor = .blue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SurahCollectionViewCell else { return }
        cell.removeViews()
        
        let updateCellClosure: (Verse?) -> Void = { [weak self] verse in
            guard let self = self else {
                return
            }
            cell.updateAppearanceFor(verse: verse, animated: true)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
        
        if let dataLoader = loadingOperations[indexPath] {
            if dataLoader.state == .finished{
                cell.updateAppearanceFor(verse: dataLoader.verse, animated: false)
                loadingOperations.removeValue(forKey: indexPath)
            } else {
                dataLoader.loadingCompleteHandler = updateCellClosure
            }
        } else {
            let dataLoader = VerseDataLoaderOperation(chapter: self.chapter, verseIdx: indexPath.row)
            dataLoader.loadingCompleteHandler = updateCellClosure
            loadingQueue.addOperation(dataLoader)
            loadingOperations[indexPath] = dataLoader
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let dataLoader = loadingOperations[indexPath] {
            dataLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

extension SurahCollectionView: UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            print("prefetching \(indexPath.row)")
            if let _ = loadingOperations[indexPath] {
                continue
            }
            let dataLoader = VerseDataLoaderOperation(chapter: self.chapter, verseIdx: indexPath.row)
            loadingQueue.addOperation(dataLoader)
            loadingOperations[indexPath] = dataLoader
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let dataLoader = loadingOperations[indexPath] {
                dataLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
    }
    
}

