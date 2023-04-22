//
//  SettingsVC.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 21/4/23.
//

import UIKit


import Foundation


class SettingsVC: UITableViewController {
    
    let settingsData: SettingsData = SettingsData.shared
    
    @IBOutlet weak var systemModeSwitch: UISwitch!{
        didSet{
            systemModeSwitch.isOn = settingsData.systemMode ? true : false
            systemModeSwitch.addAction(UIAction(handler: {_ in
                self.settingsData.systemMode = self.systemModeSwitch.isOn
            }), for: .valueChanged)
        }
    }
    @IBOutlet weak var darkModeSwitch: UISwitch!{
        didSet{
            darkModeSwitch.isOn = settingsData.darkMode ? true : false
            darkModeSwitch.addAction(UIAction(handler: {_ in
                self.settingsData.darkMode = self.darkModeSwitch.isOn
            }), for: .valueChanged)
        }
    }
    @IBOutlet weak var transliterationSwitch: UISwitch!{
        didSet{
            transliterationSwitch.isOn = settingsData.shouldShowTransliteration ? true : false
            transliterationSwitch.addAction(UIAction(handler: {_ in
                self.settingsData.shouldShowTransliteration = self.transliterationSwitch.isOn
            }), for: .valueChanged)
        }
    }
    @IBOutlet weak var translationLanguageBtn: UIButton!
    @IBOutlet weak var translationReciterBtn: UIButton!
    
    
    @IBOutlet weak var wordByWordTranslationSwitch: UISwitch!{
        didSet{
            wordByWordTranslationSwitch.isOn = settingsData.wordByWordTranslation ? true : false
            wordByWordTranslationSwitch.addAction(UIAction(handler: {_ in
                self.settingsData.wordByWordTranslation = self.wordByWordTranslationSwitch.isOn
                self.wordByWordTranslationLanguageBtn.isEnabled = self.wordByWordTranslationSwitch.isOn
                            
            }), for: .valueChanged)
        }
    }
    @IBOutlet weak var saveOfflineAudioSwitch: UISwitch!{
        didSet{
            saveOfflineAudioSwitch.isOn = settingsData.offlineAudioDownload ? true : false
            
            saveOfflineAudioSwitch.addAction(UIAction(handler: {_ in
                self.settingsData.offlineAudioDownload = self.saveOfflineAudioSwitch.isOn
            }), for: .valueChanged)
        }
    }
    @IBOutlet weak var wordByWordTranslationLanguageBtn: UIButton!
    
    @IBOutlet weak var audioReciterBtn: UIButton!
    
    @IBOutlet weak var markProbableWordSwitch: UISwitch!{
        didSet{
            markProbableWordSwitch.isOn = settingsData.shouldMarkProbableWord ? true : false
            
            markProbableWordSwitch.addAction(UIAction(handler: {_ in
                self.settingsData.shouldMarkProbableWord = self.markProbableWordSwitch.isOn
            }), for: .valueChanged)
        }
    }
    @IBOutlet weak var autoScrollSwitch: UISwitch!{
        didSet{
            autoScrollSwitch.isOn = settingsData.shouldAutoScroll ? true : false
            
            autoScrollSwitch.addAction(UIAction(handler: {_ in
                self.settingsData.shouldAutoScroll = self.autoScrollSwitch.isOn
            }), for: .valueChanged)
        }
    }
    @IBOutlet weak var fontSizeBtn: UIButton!
    
    private var sharedItem: QuranSharedItem!{
        didSet{
            self.loadDropDownMenusForTranslation()
            self.loadWordByWordTranslationLanguage()
            self.loadAudioReciters()
            self.wordByWordTranslationLanguageBtn.isEnabled = self.wordByWordTranslationSwitch.isOn
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QuranSharedItem.getSharedItem { [weak self] sharedItem in
            self?.sharedItem = sharedItem
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func clearAudioBtn(_ sender: Any) {
        
        
    }
    
    func loadDropDownForTranslationReciters(with infos : [TranslationInfo]){
        
        let handler = { [weak self] (action: UIAction) in
            guard let self = self else {
                return
            }
            
            for info in infos {
                if info.name == action.title{
                    self.settingsData.translationReciterId = info.id!
                    self.translationReciterBtn.setTitle(action.title, for: .normal)
                    break
                }
            }
        }
        
        var actions: [UIAction] = []
        for info in infos {
            actions.append(UIAction(title: info.name ?? "", handler: handler))
        }
        self.translationReciterBtn.menu = UIMenu(children: actions)
        
        var ifFound = false
        for info in infos {
            if info.id == settingsData.translationReciterId{
                self.translationReciterBtn.setTitle(info.name, for: .normal)
                ifFound = true
                break
            }
        }
        if !ifFound{
            let info = infos.first!
            self.translationReciterBtn.setTitle(info.name, for: .normal)
            self.settingsData.translationReciterId = info.id!
        }
        
    }

    func loadDropDownMenusForTranslation(){
        let reciters = sharedItem.getTranslationInfos()
        
        let languages = reciters.keys
        
        let handler = { [weak self] (action: UIAction) in
            guard let self = self else {
                return
            }
            
            for language in languages {
                if language.name == action.title{
                    self.translationLanguageBtn.setTitle(action.title, for: .normal)
                    self.settingsData.translationLanguageISO = language.iso_code!
                    self.loadDropDownForTranslationReciters(with: reciters[language]!)
                    break
                }
            }
        }
        
        var actions: [UIAction] = []
        for language in languages{
            actions.append(UIAction(title: language.name ?? "", handler: handler))
        }
        self.translationLanguageBtn.menu = UIMenu(children: actions)
        
        
        for language in languages {
            if language.iso_code == settingsData.translationLanguageISO{
                self.translationLanguageBtn.setTitle(language.name, for: .normal)
                self.loadDropDownForTranslationReciters(with: reciters[language]!)
                break
            }
        }
    }
    
    func loadWordByWordTranslationLanguage(){
        let languages = sharedItem.getLanguages()!
        
        let handler = { [weak self] (action: UIAction) in
            guard let self = self else {
                return
            }
            
            for language in languages {
                if language.name == action.title{
                    self.wordByWordTranslationLanguageBtn.setTitle(action.title, for: .normal)
                    self.settingsData.wordByWordTranslationLanguageISO = language.iso_code!
                    break
                }
            }
        }
        
        var actions: [UIAction] = []
        for language in languages{
            actions.append(UIAction(title: language.name ?? "", handler: handler))
        }
        self.wordByWordTranslationLanguageBtn.menu = UIMenu(children: actions)
        
        
        for language in languages {
            if language.iso_code == settingsData.wordByWordTranslationLanguageISO{
                self.wordByWordTranslationLanguageBtn.setTitle(language.name, for: .normal)
                break
            }
        }
    }
    
    func loadAudioReciters(){
        let reciters = sharedItem.getAudioReciters()
        
        let handler = { [weak self] (action: UIAction) in
            guard let self = self else {
                return
            }
            for reciter in reciters {
                if reciter.name == action.title{
                    self.audioReciterBtn.setTitle(action.title, for: .normal)
                    self.settingsData.audioReciterId = reciter.id!
                    break
                }
            }
        }
        
        var actions: [UIAction] = []
        for reciter in reciters {
            actions.append(UIAction(title: reciter.name ?? "", handler: handler))
        }
        self.audioReciterBtn.menu = UIMenu(children: actions)
        
        for reciter in reciters {
            if reciter.id == settingsData.audioReciterId{
                self.audioReciterBtn.setTitle(reciter.name, for: .normal)
                break
            }
        }
    }
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 3
    //    }
    //
    //    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        // #warning Incomplete implementation, return the number of rows
    //        return 3
    //    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
