//
//  SettingsView.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 02/09/2021.
//

import Foundation
import UIKit

class SettingsView: UIViewController
{
    let userDefaults = UserDefaults.standard;
    
    @IBOutlet weak var DeviceIPLabel: UILabel!
    @IBOutlet weak var DeviceIPEditBtn: UIButton!
    
    @IBOutlet weak var DevicePortLabel: UILabel!
    @IBOutlet weak var DevicePortEditBtn: UIButton!
    
    @IBOutlet weak var DeviceWifiPasswordLabel: UILabel!
    @IBOutlet weak var DeviceWifiPasswordEditBtn: UIButton!
    
    
    
    @IBAction func handleExitSettings(_ segue:UIStoryboardSegue)
    {
        
    }
    
    override func viewDidLoad() {
        refreshLabels()
        super.viewDidLoad()
    }
    
    //NOTE IT WAS CHANGED TO DeviceWiFi
    @IBAction func DeviceIPEditBtnPressed(_ sender: UIButton) {
        let userDefaultsKey = "DeviceWiFi"
        var deviceIP = self.userDefaults.string(forKey: userDefaultsKey)
        if(deviceIP == nil)
        {
            deviceIP = "NOT SET"
        }
        showEditAlert(alertTitle: "Edit device WiFi", alertMessage: "Please enter new device WiFi", alertTextFieldValue: deviceIP!, userDefaultsKey: userDefaultsKey)
    }
    
    @IBAction func DeviceWifiPassEditBtnPressed(_ sender: UIButton) {
        let userDefaultsKey = "DeviceWifiPassword"
        var deviceWifiPass = self.userDefaults.string(forKey: userDefaultsKey)
        if(deviceWifiPass == nil)
        {
            deviceWifiPass = "NOT SET"
        }
        showEditAlert(alertTitle: "Edit device wifi password", alertMessage: "Please enter new device wifi password", alertTextFieldValue: deviceWifiPass!, userDefaultsKey: userDefaultsKey)
    }
    
    
    private func showEditAlert(alertTitle: String, alertMessage: String, alertTextFieldValue: String, userDefaultsKey: String)
    {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        var editedVal = self.userDefaults.string(forKey: userDefaultsKey)
        if(editedVal == nil)
        {
            editedVal = "NOT SET"
        }
        
        alert.addTextField{
            (textField) in textField.text = alertTextFieldValue
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            [weak alert] (_) in let textField = alert?.textFields![0]
            print("Text field: \(textField!.text)")
            editedVal = textField!.text!
            self.userDefaults.set(editedVal, forKey: userDefaultsKey)
            self.refreshLabels()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func refreshLabels()
    {
        var deviceWifi =  userDefaults.string(forKey: "DeviceWiFi")
        if(deviceWifi == nil)
        {
            deviceWifi = "NOT SET"
        }
        DeviceIPLabel.text = deviceWifi
        
        var devWifiPass = userDefaults.string(forKey: "DeviceWifiPassword")
        if(devWifiPass == nil)
        {
            devWifiPass = "NOT SET"
        }
        DeviceWifiPasswordLabel.text = devWifiPass
    }
}
