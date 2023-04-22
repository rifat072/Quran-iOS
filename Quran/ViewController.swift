//
//  ViewController.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 18/4/23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var btnLoadSurah: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PlayerManager.shared.configureFloatingPanel(navControl: self.navigationController!)
//        self.btnLoadSurahPressed(btnLoadSurah)
    }
    @IBAction func btnLoadSurahPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SurahListVC", bundle: .main)
        let vc = storyboard.instantiateViewController(withIdentifier: "SurahListVC")
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func settingsPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingHostingVC")
        self.present(vc, animated: true)
    }
    
}

