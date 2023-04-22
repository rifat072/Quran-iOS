////
////  SurahCollectionView.swift
////  Quran
////
////  Created by Md. Rifat Haider Chowdhury on 19/4/23.
////
//
//import UIKit
//
//protocol SurahCollectionViewDelegate: NSObject{
//    func isReadyForStream()
//}
//
//class SurahCollectionView: UICollectionView {
//    
//    static let lineHeight: Int = 70
//    private static let wordSpacing: CGFloat = 15
//    weak var viewControllerDelegate: SurahCollectionViewDelegate? = nil
//    private var verseViewModels: [VerseViewModel?] = []
//    
//    var chapter: Chapter!{
//        didSet{
//            Task{
//                do{
//                    try await self.chapter.loadAllVerses()
//                    for i in 0..<chapter.getVersesCount(){
//                        if let verse = try self.chapter.getVerse(idx: i){
//                            verseViewModels.append(VerseViewModel(verse: verse))
//                        }
//                    }
//                    self.delegate = self
//                    self.dataSource = self
//                    self.viewControllerDelegate?.isReadyForStream()
//                    PlayerManager.shared.continousReadingDelegate = self
//                } catch{
//                    print("Cannot Load Data")
//                    //TODO: Should show retry
//                }
//                
//            }
//        }
//    }
//    
//    
//    //PlayerMarking Variables
//    weak var currentMarkedView: UIView? = nil
//    var currentMarkingIndex: Int = 0
//    var currentverse: Verse? = nil
//    var totalDuration: Float = .zero
//    var currentVerseViewModel: VerseViewModel? = nil
//    
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.register(UINib(nibName: SurahCollectionViewCell.reuseIdentifier, bundle:.main), forCellWithReuseIdentifier: SurahCollectionViewCell.reuseIdentifier)
//        
//        
////        func testing(){
////            DispatchQueue.main.async {
////                self.performBatchUpdates {
////                    print("Rifat Peform")
////                } completion: { com in
////                    print("Rifat Completion \(com)")
////                }
////
////            }
////            Thread.sleep(forTimeInterval: 1.0)
////            testing()
////        }
////        DispatchQueue.global().async {
////            testing()
////        }
//        
//        
//    }
//    
//}
//
//extension SurahCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return chapter.getVersesCount()
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SurahCollectionViewCell.reuseIdentifier, for: indexPath)
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard let cell = cell as? SurahCollectionViewCell else { return }
//        if let verseViewModel = self.verseViewModels[indexPath.row]{
//            cell.updateAppearanceFor(verseViewModel: verseViewModel, wordSpacing: SurahCollectionView.wordSpacing)
//        }
//    }
//    
//
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if let viewModel = self.verseViewModels[indexPath.row]{
//            let lineCount = viewModel.getLineCount(maxWidth: collectionView.bounds.width, itemSpacing: SurahCollectionView.wordSpacing)
//            return CGSize(width: collectionView.bounds.width, height: CGFloat(lineCount * SurahCollectionView.lineHeight + 40 + 100))
//        }
//        return .zero
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 20
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 20
//    }
//}
//
//extension SurahCollectionView: ContinouseReadingDelegate{
//    
//    func markView(newView: UIStackView?){
//        if SettingsData.shared.shouldMarkProbableWord == false {
//            return
//        }
//        if let view = self.currentMarkedView{
//            let subViews = view.subviews
//            for subView in subViews {
//                let label = subView as! UILabel
//                label.textColor = .white
//            }
//        }
//        self.currentMarkedView = newView
//        
//        if let view = self.currentMarkedView{
//            let subViews = view.subviews
//            for subView in subViews {
//                let label = subView as! UILabel
//                label.textColor = UIColor(named: "cellSelectedColor")
//            }
//        }
//    }
//    func currentProgress(value: Float) {
//        if value.isNaN {
//            return
//        }
//        if self.currentMarkingIndex < self.currentverse?.audio?.segments.count ?? 0{
//            let segement = self.currentverse!.audio!.segments[currentMarkingIndex]
//            let segmetntTotalDuration = self.currentverse!.audio!.segments.last![3]
//            
//            let currentSegmentTime = (value * Float(segmetntTotalDuration)) / totalDuration
//            
//            if Int(currentSegmentTime) >= segement[2] && Int(currentSegmentTime) <= segement[3]{
//                self.markView(newView: self.currentVerseViewModel?.wordViewModels[self.currentMarkingIndex].lastGeneratedView as? UIStackView)
//                currentMarkingIndex += 1
//            }
//            
//        }
//    }
//    
//    func setTotalDuration(value: Float) {
//        if value.isNaN {
//            return
//        }
//        self.totalDuration = value
//    }
//    
//    func setVerse(verse: Verse) {
//        let key = verse.verse_key.split(separator: ":")
//        self.currentMarkingIndex = 0
//        
//        if Int(key[0]) == self.chapter.id{
//            self.currentverse = verse
//            self.currentVerseViewModel = verseViewModels[Int(key[1])! - 1]
//            if SettingsData.shared.shouldAutoScroll{
//                self.scrollToItem(at: IndexPath(row: Int(key[1])! - 1, section: 0), at: .top, animated: true)
//            }
//        } else {
//            self.currentverse = nil
//            self.totalDuration = .zero
//            self.currentVerseViewModel = nil
//            self.markView(newView: nil)
//        }
//    }
//}
