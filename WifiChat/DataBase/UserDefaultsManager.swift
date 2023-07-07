//
//  UserDefaultsManager.swift
//  WifiChat
//
//  Created by Nurillo Domlajonov on 09/06/23.
//


import Foundation
import UIKit

class UserDefaultsManager{
    
    static let shared = UserDefaultsManager()
    let defaults = UserDefaults.standard
    
    
    //MARK: SET
    func saveMessage(messages: [String]){
        UserDefaults.standard.set(messages, forKey: "message")
    }
    
    func loadMessage() -> [String] {
        let array =  UserDefaults.standard.array(forKey: "message") as? [String] ?? [String]()
        return array
    }
    
    
    func saveDevice(devices: [String]){
        UserDefaults.standard.set(devices, forKey: "device")
    }
    
    func loadDevice() -> [String] {
        let array =  UserDefaults.standard.array(forKey: "device") as? [String] ?? [String]()
        return array
    }
}
