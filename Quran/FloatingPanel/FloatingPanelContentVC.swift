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
    var lines: [UIView]? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.roundCorners(corners: [.topLeft, .topLeft], radius: 15)

        // Do any additional setup after loading the view.
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
        self.lines = verse.generateLines(wordSpacing: 15, lineMaxWidth: self.tableView.bounds.width)
        self.tableView.reloadData()
    }

}


extension FloatingPanelContentVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lines?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: FloatingPanelContentVC.reuseIdentifier)!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let line = lines?[indexPath.row],
           let stackView = cell.viewWithTag(1) as? UIStackView{
            for view in stackView.subviews{
                view.removeFromSuperview()
            }
            stackView.addArrangedSubview(line)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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
