//
//  SurahVC.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 19/4/23.
//

import UIKit

class SurahVC: UIViewController {
    
    var chapter: Chapter!

    @IBOutlet weak var collectionView: SurahCollectionView!{
        didSet{
            self.collectionView.chapter = self.chapter
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
