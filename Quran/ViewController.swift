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
        
        Task{
            do{
                let sharedItem = try await QuranSharedItem.getSharedItem()
                let storyboard = UIStoryboard(name: "SurahListVC", bundle: .main)
                let vc = storyboard.instantiateViewController(withIdentifier: "SurahListVC") as! SurahListVC
                vc.quran = sharedItem
                self.navigationController?.pushViewController(vc, animated: true)
            } catch{
                print(error.localizedDescription)
            }
            
        }

    }
    

}

