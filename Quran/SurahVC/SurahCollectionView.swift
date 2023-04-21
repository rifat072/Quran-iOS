//
//  SurahCollectionView.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 19/4/23.
//

import UIKit

protocol SurahCollectionViewDelegate: NSObject{
    func isReadyForStream()
}

class SurahCollectionView: UICollectionView {
    
    static let lineHeight: Int = 70
    private static let wordSpacing: CGFloat = 15
    weak var viewControllerDelegate: SurahCollectionViewDelegate? = nil
    
    private var verseViewModels: [VerseViewModel?] = []
    var chapter: Chapter!{
        didSet{
            Task{
                do{
                    try await self.chapter.loadAllVerses()
                    for i in 0..<chapter.getVersesCount(){
                        if let verse = try self.chapter.getVerse(idx: i){
                            verseViewModels.append(VerseViewModel(verse: verse))
                        }
                    }
                    self.delegate = self
                    self.dataSource = self
                    self.viewControllerDelegate?.isReadyForStream()
                } catch{
                    print("Cannot Load Data")
                    //TODO: Should show retry
                }
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.register(UINib(nibName: SurahCollectionViewCell.reuseIdentifier, bundle:.main), forCellWithReuseIdentifier: SurahCollectionViewCell.reuseIdentifier)
    }
    
}

extension SurahCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chapter.getVersesCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SurahCollectionViewCell.reuseIdentifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SurahCollectionViewCell else { return }
        if let verseViewModel = self.verseViewModels[indexPath.row]{
            cell.updateAppearanceFor(verseViewModel: verseViewModel, wordSpacing: SurahCollectionView.wordSpacing)
        }
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let viewModel = self.verseViewModels[indexPath.row]{
            let lineCount = viewModel.getLineCount(maxWidth: collectionView.bounds.width, itemSpacing: SurahCollectionView.wordSpacing)
            return CGSize(width: collectionView.bounds.width, height: CGFloat(lineCount * SurahCollectionView.lineHeight + 40))
        }
        return .zero
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}


extension Verse{
    

}
