//
//  FloatingView.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 20/4/23.
//

import UIKit

protocol FloatingViewDelegate: NSObject{
    func crossPressed()
}

class FloatingView: UIView {
    weak var delegate: FloatingViewDelegate? = nil
    var totalDuration: Float!{
        didSet{
            let value = secondsToHoursMinutesSeconds(Int(totalDuration))
            let str = NSString(format:"%02d:%02d:%02d", value.0, value.1, value.2)
            self.endTimeLabel.text = String(str)
        }
    }
    
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playerSlider: UISlider!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.cornerRadius = 15
        self.isHidden = true
    }
    
    
    @IBAction func sliderValueChanged(sender: UISlider){
        
    }
    
    @IBAction func crossPressed(sender: UIButton){
        self.delegate?.crossPressed()
        self.isHidden = true
    }
}


