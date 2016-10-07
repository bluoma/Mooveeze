//
//  AppearanceManager.swift
//  Mooveeze
//
//  Created by Bill on 9/12/16.
//  Copyright © 2016 BillLuoma. All rights reserved.
//  Based on https://www.raywenderlich.com/108766/uiappearance-tutorial

import UIKit


enum Theme : Int {
    case Default = 0, Dark, Light
    
    var mainColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red: 10.0/255.0, green: 10.0/255.0, blue: 143.0/255.0, alpha: 1.0)
        case .Dark:
            return UIColor(red: 242.0/255.0, green: 101.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        case .Light:
            return UIColor(red: 10.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 1.0)
        }
    }
    
    var barStyle: UIBarStyle {
        switch self {
        case .Default:
            return UIBarStyle.default
        case .Dark:
            return UIBarStyle.default
        case .Light:
            return UIBarStyle.black
        }
    }
    
   
}

class AppearanceManager
{
    static func currentTheme() -> Theme {
        let storedTheme = UserDefaults.standard.integer(forKey: defaultAppearanceKey)
        return Theme(rawValue: storedTheme)!
    }
    
    static func applyTheme(theme: Theme) {
        
        UserDefaults.standard.set(theme.rawValue, forKey: defaultAppearanceKey)
        UserDefaults.standard.synchronize()
        
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
        
        UIToolbar.appearance().barTintColor = theme.mainColor
        UIToolbar.appearance().tintColor = UIColor.white
        UIToolbar.appearance().isTranslucent = false
        
        dlog("applying theme: \(theme), navbar style: \(theme.barStyle.rawValue)")
        //UINavigationBar.appearance().barStyle = theme.barStyle  //need to apply this before nav vc is loaded. save for later.
        
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "backArrow")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "backArrowMask")
        
    }
    
}
