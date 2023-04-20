//
//  SurahListCollectionViewCell.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 18/4/23.
//

import UIKit

class SurahListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 15

    }

}
