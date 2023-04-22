//
//  SettingsData.swift
//  Quran
//
//  Created by Md. Rifat Haider Chowdhury on 21/4/23.
//

import Foundation

class SettingsData: NSObject{
    
    enum FontSize: Int, CaseIterable{
        case Small
        case Medium
        case Large
    }
    

    static let shared = SettingsData()
    
    private let userDefaults: UserDefaults = UserDefaults(suiteName: "SettingsData")!
    

    var shouldAutoScroll: Bool{
        get{
            return self.userDefaults.bool(forKey: "shouldAutoScroll")
        } set {
            self.userDefaults.set(newValue, forKey: "shouldAutoScroll")
        }
    }
    var shouldMarkProbableWord: Bool{
        get{
            return self.userDefaults.bool(forKey: "shouldMarkProbableWord")
        } set {
            self.userDefaults.set(newValue, forKey: "shouldMarkProbableWord")
        }
    }
    var darkMode: Bool{
        get{
            return self.userDefaults.bool(forKey: "darkMode")
        } set {
            self.userDefaults.set(newValue, forKey: "darkMode")
        }
    }
    var systemMode: Bool{
        get{
            return self.userDefaults.bool(forKey: "systemMode")
        } set {
            self.userDefaults.set(newValue, forKey: "systemMode")
        }
    }
    var shouldShowEnglishWordTranslation: Bool{
        get{
            return self.userDefaults.bool(forKey: "shouldShowEnglishWordTranslation")
        } set {
            self.userDefaults.set(newValue, forKey: "shouldShowEnglishWordTranslation")
        }
        
    }
    var shouldShowTransliteration: Bool{
        get{
            return self.userDefaults.bool(forKey: "shouldShowTransliteration")
        } set {
            self.userDefaults.set(newValue, forKey: "shouldShowTransliteration")
        }
    }
    var selectedFontSize: FontSize{
        get{
            return SettingsData.FontSize(rawValue: self.userDefaults.integer(forKey: "selectedFontSize"))!
        } set {
            self.userDefaults.set(newValue.rawValue, forKey: "selectedFontSize")
        }
    }
    
    var translationLanguageISO: String{
        get{
            return self.userDefaults.string(forKey: "translationLanguageISO")!
        } set {
            self.userDefaults.set(newValue, forKey: "translationLanguageISO")
        }
    }
    var translationReciterId: Int{
        get{
            return self.userDefaults.integer(forKey: "translationReciterId")
        } set {
            self.userDefaults.set(newValue, forKey: "translationReciterId")
        }
    }
    
    private override init(){
        super.init()
        
        //TODO: Need to user version
        if self.userDefaults.bool(forKey: "isValueIntiatedFirstTime") == false {
            
            self.shouldAutoScroll = true
            self.shouldMarkProbableWord = true
            self.darkMode = false
            self.systemMode = false
            self.shouldShowEnglishWordTranslation = true
            self.shouldShowTransliteration = true
            self.selectedFontSize = .Medium
            self.translationLanguageISO = "en"
            self.translationReciterId = -1
            
            self.userDefaults.set(true, forKey: "isValueIntiatedFirstTime")
        }
    }
}

