//
//  FloatingView.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 20/4/23.
//

import UIKit

class FloatingView: UIView {
    var totalDuration: Float!{
        didSet{
            let seconds = Int(totalDuration)
            let dateComponents = DateComponents(second: seconds)
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .positional
            let formattedString = formatter.string(from: dateComponents)!
            
            self.endTimeLabel.text = formattedString
        }
    }
    
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playerSlider: UISlider!
    
    
    @IBAction func sliderValueChanged(sender: UISlider){
        
    }
}


