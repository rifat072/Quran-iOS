//
//  SuraTableView.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 22/4/23.
//

import UIKit

protocol SurahTableViewDelegate: NSObject{
    func isReadyForStream()
}


class SurahTableView: UITableView {

    static let lineHeight: Int = 70
    private static let wordSpacing: CGFloat = 15
    weak var viewControllerDelegate: SurahTableViewDelegate? = nil

    
    var chapter: Chapter!{
        didSet{
            verseViewModels = [VerseViewModel?](repeating: nil, count: self.chapter.getVersesCount())
            messedUPSize = [Bool](repeating: true, count: self.chapter.getVersesCount())
            self.estimatedRowHeight = 600
            self.delegate = self
            self.dataSource = self
            self.prefetchDataSource = self
            self.register(UINib(nibName: "SurahVCTableViewCell", bundle: .main), forCellReuseIdentifier: "SurahVCTableViewCell")
            
            self.viewControllerDelegate?.isReadyForStream()
            PlayerManager.shared.continousReadingDelegate = self
            
        }
    }
    

    private var verseViewModels: [VerseViewModel?] = []
    private var messedUPSize:[Bool] = []

    let loadingQueue = OperationQueue()
    var loadingOperations: [IndexPath: VerseDataLoaderOperation] = [:]
    

    
    //PlayerMarking Variables
    weak var currentMarkedView: UIView? = nil
    var currentMarkingIndex: Int = 0
    var currentverse: Verse? = nil
    var totalDuration: Float = .zero
    var currentVerseViewModel: VerseViewModel? = nil
    
}


extension SurahTableView: UITableViewDataSource, UITableViewDelegate{
    
    func fixedMessedUpSizeIfNeeded(indexPath: IndexPath){
        if messedUPSize[indexPath.row]{
            print("Fixed \(indexPath.row)")
            UIView.performWithoutAnimation {
                let loc = self.contentOffset
                self.beginUpdates()
                self.endUpdates()
                self.contentOffset = loc
            }
            messedUPSize[indexPath.row] = false
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapter.getVersesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SurahVCTableViewCell") as! SurahVCTableViewCell
        
        cell.removeViews()

        let updateCellClosure: (VerseViewModel?) -> Void = { [weak self] viewModel in
            guard let self = self else {
                return
            }
            self.verseViewModels[indexPath.row] = viewModel
            cell.updateAppearanceFor(verseViewModel: self.verseViewModels[indexPath.row]!, wordSpacing: SurahTableView.wordSpacing)
            self.loadingOperations.removeValue(forKey: indexPath)

            self.fixedMessedUpSizeIfNeeded(indexPath: indexPath)


        }

        if let dataLoader = loadingOperations[indexPath] {
            if dataLoader.state == .finished{
                self.verseViewModels[indexPath.row] = dataLoader.verseViewModel
                cell.updateAppearanceFor(verseViewModel: dataLoader.verseViewModel!, wordSpacing: SurahTableView.wordSpacing)
                loadingOperations.removeValue(forKey: indexPath)

                self.fixedMessedUpSizeIfNeeded(indexPath: indexPath)
            } else {
                dataLoader.loadingCompleteHandler = updateCellClosure
            }
        } else {
            let dataLoader = VerseDataLoaderOperation(chapter: self.chapter, verseIdx: indexPath.row)
            dataLoader.loadingCompleteHandler = updateCellClosure
            loadingQueue.addOperation(dataLoader)
            loadingOperations[indexPath] = dataLoader
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let dataLoader = loadingOperations[indexPath] {
            dataLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? SurahVCTableViewCell else {
            return
        }
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let viewModel = self.verseViewModels[indexPath.row]{
            messedUPSize[indexPath.row] = false
            let lineCount = viewModel.getLineCount(maxWidth: tableView.bounds.width, itemSpacing: SurahTableView.wordSpacing)
            return CGFloat(lineCount * SurahTableView.lineHeight) + 100
        } else{
            messedUPSize[indexPath.row] = true
        }
        return 600
    }
    
}

extension SurahTableView: UITableViewDataSourcePrefetching{
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let _ = loadingOperations[indexPath] {
                continue
            }
            let dataLoader = VerseDataLoaderOperation(chapter: self.chapter, verseIdx: indexPath.row)
            loadingQueue.addOperation(dataLoader)
            loadingOperations[indexPath] = dataLoader
        }
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let dataLoader = loadingOperations[indexPath] {
                dataLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
    }
}



extension SurahTableView: ContinouseReadingDelegate{
    
    func markView(newView: UIStackView?){
        if SettingsData.shared.shouldMarkProbableWord == false {
            return
        }
        if let view = self.currentMarkedView{
            let subViews = view.subviews
            for subView in subViews {
                let label = subView as! UILabel
                label.textColor = .white
            }
        }
        self.currentMarkedView = newView
        
        if let view = self.currentMarkedView{
            let subViews = view.subviews
            for subView in subViews {
                let label = subView as! UILabel
                label.textColor = UIColor(named: "cellSelectedColor")
            }
        }
    }
    func currentProgress(value: Float) {
        if value.isNaN {
            return
        }
        if self.currentMarkingIndex < self.currentverse?.audio?.segments.count ?? 0{
            let segement = self.currentverse!.audio!.segments[currentMarkingIndex]
            let segmetntTotalDuration = self.currentverse!.audio!.segments.last![3]
            
            let currentSegmentTime = (value * Float(segmetntTotalDuration)) / totalDuration
            
            if Int(currentSegmentTime) >= segement[2] && Int(currentSegmentTime) <= segement[3]{
                self.markView(newView: self.currentVerseViewModel?.wordViewModels[self.currentMarkingIndex].lastGeneratedView as? UIStackView)
                currentMarkingIndex += 1
            }
            
        }
    }
    
    func setTotalDuration(value: Float) {
        if value.isNaN {
            return
        }
        self.totalDuration = value
    }
    
    func setVerse(verse: Verse) {
        let key = verse.verse_key.split(separator: ":")
        self.currentMarkingIndex = 0
        
        if Int(key[0]) == self.chapter.id{
            self.currentverse = verse
            self.currentVerseViewModel = verseViewModels[Int(key[1])! - 1]
            if SettingsData.shared.shouldAutoScroll{
                self.scrollToRow(at: IndexPath(row: Int(key[1])! - 1, section: 0), at: .top, animated: true)
            }
        } else {
            self.currentverse = nil
            self.totalDuration = .zero
            self.currentVerseViewModel = nil
            self.markView(newView: nil)
        }
    }
}
