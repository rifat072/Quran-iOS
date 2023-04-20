//
//  SurahCollectionViewCell.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 19/4/23.
//

import UIKit

class SurahCollectionViewCell: UICollectionViewCell {

    public static let reuseIdentifier = "SurahCollectionViewCell"
    
    @IBOutlet weak var controlView: UIView!
    
    @IBOutlet weak var containerStackView: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    func updateAppearanceFor(verse: Verse?, wordSpacing: CGFloat){
        let views = containerStackView.subviews
        for view in views{
            view.removeFromSuperview()
        }
        
        let lines = verse?.generateLines(wordSpacing: wordSpacing, lineMaxWidth: self.bounds.width) ?? []
        
        for line in lines {
            containerStackView.addArrangedSubview(line)
        }
    }

}







extension UILabel {
    
    func textWidth() -> CGFloat {
        return UILabel.textWidth(label: self)
    }

    class func textWidth(label: UILabel) -> CGFloat {
        if label.text == nil {return 0}
        return textWidth(label: label, text: label.text!)
    }

    class func textWidth(label: UILabel, text: String) -> CGFloat {
        return textWidth(font: label.font, text: text)
    }

    class func textWidth(font: UIFont, text: String) -> CGFloat {
        return textSize(font: font, text: text).width
    }

    class func textHeight(withWidth width: CGFloat, font: UIFont, text: String) -> CGFloat {
        return textSize(font: font, text: text, width: width).height
    }

    class func textSize(font: UIFont, text: String, extra: CGSize) -> CGSize {
        var size = textSize(font: font, text: text)
        size.width = size.width + extra.width
        size.height = size.height + extra.height
        return size
    }

    class func textSize(font: UIFont, text: String, width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.numberOfLines = 0
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.size
    }

    class func countLines(font: UIFont, text: String, width: CGFloat, height: CGFloat = .greatestFiniteMagnitude) -> Int {
        // Call self.layoutIfNeeded() if your view uses auto layout
        let myText = text as NSString

        let rect = CGSize(width: width, height: height)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
    }

    func countLines(width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> Int {
//         Call self.layoutIfNeeded() if your view uses auto layout
        self.layoutIfNeeded()
        let myText = (self.text ?? "") as NSString

        let rect = CGSize(width: width, height: height)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font as Any], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }
}


extension Word{
    func generateDisplayView() -> (view: UIView, width: CGFloat){
        
        func generateLabel(str: String?) -> UILabel{
            let label = UILabel()
            label.text = str
            label.textColor = .white
            label.textAlignment = .center
            return label
        }
        
        var maxWidth: CGFloat = 0
        let label1 = generateLabel(str: self.text_uthmani)
        label1.font = UIFont.systemFont(ofSize: 15)
        maxWidth = max(maxWidth, label1.textWidth())
        let label2 = generateLabel(str: self.transliteration.text)
        label2.font = UIFont.systemFont(ofSize: 11)
        maxWidth = max(maxWidth, label2.textWidth())
        let label3 = generateLabel(str: self.translation.text)
        label3.font = UIFont.systemFont(ofSize: 11)
        maxWidth = max(maxWidth, label3.textWidth())
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.addArrangedSubview(label1)
        stackView.addArrangedSubview(label2)
        stackView.addArrangedSubview(label3)
        
        return (view: stackView, width: maxWidth)
    }
}

extension Verse{
    func generateLines(wordSpacing: CGFloat, lineMaxWidth: CGFloat) -> [UIView]{
        if self.words == nil{ return [] }
        
        func generateNewLine() -> UIStackView{
            let stackView = UIStackView()
            stackView.backgroundColor = .red
            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            stackView.alignment = .center
            stackView.spacing = wordSpacing
            return stackView
        }
        
        var lines: [UIView] = []
        
        var currentWordCount: CGFloat = 0
        var currentLine: UIStackView? = generateNewLine()
        var currentLineWidth: CGFloat = 0
        
        
        func addToLine(view: UIView, width: CGFloat){
            if(width + currentLineWidth + (wordSpacing * currentWordCount) > lineMaxWidth){
                if let _currentLine = currentLine{
                    lines.append(_currentLine)
                    currentLine = generateNewLine()
                    currentLineWidth = 0
                    currentWordCount = 0
                }
            }
            currentLine?.insertArrangedSubview(view, at: 0)
            currentLineWidth += width
            currentWordCount += 1
        }

        for word in self.words!{
            if word.char_type_name == "end" {
                continue
            }
            let wordDisplay = word.generateDisplayView()

            addToLine(view: wordDisplay.view, width: wordDisplay.width)
        }
        
        if let _currentLine = currentLine{
            lines.append(_currentLine)
        }
        return lines
    }
}
