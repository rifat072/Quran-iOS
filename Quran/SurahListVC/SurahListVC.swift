//
//  SurahListVC.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 18/4/23.
//

import UIKit

class SurahListVC: UIViewController {
    public static let reuseIdentifier = "SurahListCollectionViewCell"
    
    @IBOutlet weak var headView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            Task{
                self.quran = try await QuranSharedItem.getSharedItem()
                collectionView.delegate = self
                collectionView.dataSource = self
                self.collectionView.register(UINib(nibName: SurahListVC.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: SurahListVC.reuseIdentifier)
            }  
        }
    }
    
    var quran: QuranSharedItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


}



extension SurahListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quran.chapterCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SurahListVC.reuseIdentifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? SurahListCollectionViewCell,
           let chapter = quran.getChapter(for: indexPath.row){
            cell.firstLabel.text = chapter.name_arabic
            cell.secondLabel.text = chapter.name_simple
            cell.thirdLabel.text = chapter.translated_name.name
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let chapter = quran.getChapter(for: indexPath.row){
            let storyBoard = UIStoryboard(name: "SurahVC", bundle: .main)
            let vc = storyBoard.instantiateViewController(withIdentifier: "SurahVC") as! SurahVC
            vc.chapter = chapter
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    
    
}
