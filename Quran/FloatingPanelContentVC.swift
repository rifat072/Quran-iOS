//
//  FloatingPanelContentViewController.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 20/4/23.
//

import UIKit
import FloatingPanel

class MyFloatingPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip
    let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
                .full: FloatingPanelLayoutAnchor(absoluteInset: 18.0, edge: .top, referenceGuide: .safeArea),
        .half: FloatingPanelLayoutAnchor(fractionalInset: 0.7, edge: .bottom, referenceGuide: .safeArea),
        .tip: FloatingPanelLayoutAnchor(absoluteInset: 200, edge: .bottom, referenceGuide: .safeArea),
    ]
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        switch state {
        case .full, .half: return 0.3
        default: return 0.0
        }
    }
}


protocol FloatingPanelContentVCDelegate: PlayerManager{
    func prevBtnPressed()
    func playButtonPressed()
    func nextButtonPressed()
    func progressSliderChanged(value: Float)
}

class FloatingPanelContentVC: UIViewController {
    
    private static let reuseIdentifier = "FloatingPanelVerseTableViewCell"
    private static let translationReuseIdentifer = "FloatingPanelVerseTableViewCellTranslation"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    
    weak var delgate: FloatingPanelContentVCDelegate? = nil
    var verse: Verse? = nil
    var verseViewModel: VerseViewModel? = nil
    var lines: [UIView] = []
    
    //PlayerMarking Variables
    weak var currentMarkedView: UIView? = nil
    var currentMarkingIndex: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.roundCorners(corners: [.topLeft, .topLeft], radius: 15)

    }
    @IBAction func prevBtnPressed(_ sender: Any) {
        self.delgate?.prevBtnPressed()
    }
    @IBAction func playButtonPressed(_ sender: Any) {
        self.delgate?.playButtonPressed()
    }
    @IBAction func nextButtonPressed(_ sender: Any) {
        self.delgate?.nextButtonPressed()
    }
    @IBAction func progressSliderChanged(_ sender: UISlider) {
        self.delgate?.progressSliderChanged(value: sender.value)
        
    }
    
    func markView(newView: UIStackView?){
        if SettingsData.shared.shouldMarkProbableWord == false {
            return
        }
        if let view = self.currentMarkedView{
            let subViews = view.subviews
            for subView in subViews {
                let label = subView as! UILabel
                label.textColor = .white
            }
        }
        self.currentMarkedView = newView
        
        if let view = self.currentMarkedView{
            let subViews = view.subviews
            for subView in subViews {
                let label = subView as! UILabel
                label.textColor = UIColor(named: "cellSelectedColor")
            }
        }
    }

    deinit{
        print("Deinit FloatingPanelContentVC")
    }
    
    
    private func secondsToHoursMinutesSeconds(_ seconds: Int) -> String {
        let value =  (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        return String(format:"%02d:%02d:%02d", value.0, value.1, value.2)
    }
    func setTitle(title: String){
        self.titleLabel.text = title
    }
    
    func playerStopped(){
        self.playButton.imageView?.image = UIImage(named: "play")
        
    }
    func playerPlay(){
        self.playButton.imageView?.image = UIImage(named: "pause")
    }
    func currentProgress(value: Float){
        if value.isNaN {
            return
        }
        self.currentTimeLabel.text = secondsToHoursMinutesSeconds(Int(value))
        
        if self.currentMarkingIndex < self.verse?.audio?.segments.count ?? 0{
            let segement = self.verse!.audio!.segments[currentMarkingIndex]
            let segmetntTotalDuration = self.verse!.audio!.segments.last![3]
            
            let totalDuration = self.progressSlider.maximumValue
            
            let currentSegmentTime = (value * Float(segmetntTotalDuration)) / totalDuration
            
            if Int(currentSegmentTime) >= segement[2] && Int(currentSegmentTime) <= segement[3]{
                self.markView(newView: self.verseViewModel?.wordViewModels[self.currentMarkingIndex].lastGeneratedView as? UIStackView)
                currentMarkingIndex += 1
            }
            
        }
        self.progressSlider.setValue(value, animated: true)
    }
    
    func setTotalDuration(value: Float){
        if value.isNaN {
            return
        }
        self.totalTimeLabel.text = secondsToHoursMinutesSeconds(Int(value))
        self.progressSlider.maximumValue = value
    }
    
    func setVerse(verse: Verse){
        self.verse = verse
        self.verseViewModel = VerseViewModel(verse: verse)
        self.lines = self.verseViewModel?.generateDisplayView(wordSpacing: 15, lineMaxWidth: self.tableView.bounds.width) ?? []
        self.currentMarkedView = nil
        self.currentMarkingIndex = 0
        self.tableView.reloadData()
    }

}


extension FloatingPanelContentVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.verseViewModel?.getLineCount(maxWidth: tableView.bounds.width, itemSpacing: 15) ?? 0
        } else {
            return 1
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            return tableView.dequeueReusableCell(withIdentifier: FloatingPanelContentVC.reuseIdentifier)!
        } else {
            return tableView.dequeueReusableCell(withIdentifier: FloatingPanelContentVC.translationReuseIdentifer)!
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            let line = lines[indexPath.row]
            if let stackView = cell.viewWithTag(1) as? UIStackView{
                for view in stackView.subviews{
                    view.removeFromSuperview()
                }
                stackView.addArrangedSubview(line)
            }
        } else {
            if let label = cell.viewWithTag(1) as? UILabel{
                let translation = verse!.getTranslation(for: SettingsData.shared.translationReciterId)
                label.text = translation?.text
            }
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 50
        } else {
            return verseViewModel!.getTranslationViewHeight(width: tableView.bounds.width - 20) + 20 + 20
        }
        
    }
}


extension UIView {
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
