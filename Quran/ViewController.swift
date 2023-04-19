//
//  ViewController.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 18/4/23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var btnLoadSurah: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        
    }
    @IBAction func btnLoadSurahPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SurahListVC", bundle: .main)
        let vc = storyboard.instantiateViewController(withIdentifier: "SurahListVC")
        self.navigationController?.pushViewController(vc, animated: true)

    }
    

}

