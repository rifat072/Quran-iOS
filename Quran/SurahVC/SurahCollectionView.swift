//
//  SurahCollectionView.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 19/4/23.
//

import UIKit

class SurahCollectionView: UICollectionView {
    
    private static let wordSpacing: CGFloat = 15
    var chapter: Chapter!{
        didSet{
            Task{
                do{
                    try await self.chapter.loadAllVerses()
                    self.delegate = self
                    self.dataSource = self
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
        cell.backgroundColor = .blue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SurahCollectionViewCell else { return }
        do{
            let verse = try self.chapter.getVerse(idx: indexPath.row + 1)
            cell.updateAppearanceFor(verse: verse, wordSpacing: SurahCollectionView.wordSpacing)
        } catch{
            
        }
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        do{
            let verse = try self.chapter.getVerse(idx: indexPath.row + 1)
            let lineCount = verse?.getLineCount(maxWidth: collectionView.bounds.width, itemSpacing: SurahCollectionView.wordSpacing) ?? 0
            return CGSize(width: collectionView.bounds.width, height: CGFloat(lineCount * 50 + 40))
        } catch {
            return CGSize.zero
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}


extension Word{

    func getMaxWidth() -> CGFloat{
        
        func getWidth(for text: String?, size: Int) -> CGFloat{
            let label = UILabel()
            label.text = text
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: CGFloat(size))
            return label.textWidth()
        }
        
        
        var maxWidth: CGFloat = 0
        maxWidth = max(maxWidth, getWidth(for: self.text_uthmani, size: 15))
        maxWidth = max(maxWidth, getWidth(for: self.transliteration.text, size: 11))
        maxWidth = max(maxWidth, getWidth(for: self.translation.text, size: 11))
        
        return maxWidth
    }
    
}

extension Verse{
    func getLineCount(maxWidth: CGFloat, itemSpacing: CGFloat = 15) -> Int{
        if self.words == nil {return 0}

        
        var currWidth: CFloat = 0
        var lineCount: Int = 1
        
        
        for word in self.words!{
            if word.char_type_name == "end" {
                continue
            }
            var wordWidth: CGFloat = word.getMaxWidth()
            
            if CGFloat(currWidth) + wordWidth <= maxWidth {
                currWidth += Float(wordWidth + itemSpacing)
            } else {
                lineCount += 1
                currWidth = CFloat(wordWidth + itemSpacing)
            }
        }
        
        return lineCount
    }
}
