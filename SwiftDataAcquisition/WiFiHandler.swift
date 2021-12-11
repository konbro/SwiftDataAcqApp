//
//  WiFiHandler.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 04/09/2021.
//

import Foundation

import UIKit
import Network
import CocoaAsyncSocket
import NetworkExtension

class WiFiHandler {
     
    let userDefaults = UserDefaults.standard;
    
    var connection: NWConnection?
    var hostUDP: Network.NWEndpoint.Host = ""
    
    var receivedData = Array<UInt8>();
    
    //MARK:- UDP
    func connectToUDP(_ hostUDP: Network.NWEndpoint.Host, _ portUDP: Network.NWEndpoint.Port, measurements: Int) {
            
        let messageToUDP = "****"
        
          self.connection = NWConnection(host: hostUDP, port: portUDP, using: .udp)
          self.connection?.stateUpdateHandler = { (newState) in
              print("This is stateUpdateHandler:")
              switch (newState) {
                  case .ready:
                    print("State: Ready\n")
                    self.sendUDP(messageToUDP)
                    for _ in 0...measurements{
                        self.receiveUDP()
                    }
                  case .setup:
                      print("State: Setup\n")
                  case .cancelled:
                      print("State: Cancelled\n")
                  case .preparing:
                      print("State: Preparing\n")
                  default:
                      print("ERROR! State not defined!\n")
              }
          }

        print("START KJU")
        self.connection?.start(queue: .global())
        print("STOP KJU");
      }


      func sendUDP(_ content: String) {
        let contentToSendUDP = content.data(using: String.Encoding.utf8)
          self.connection?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
              if (NWError == nil) {
                  print("Data was sent to UDP")
                 DispatchQueue.main.async { print("Data was sent to UDP") }
              } else {
                  print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
              }
          })))
      }

    func receiveUDP() {
          self.connection?.receiveMessage {
            (data, context, isComplete, error) in
            if (isComplete) {
                  print("Receive is complete")
                  if (data != nil) {
                    //let backToString = String(decoding: data!, as: UTF8.self);
                    let decodedData = self.decodeData(inputData: data!)
                    self.receivedData.append(contentsOf: decodedData);
                  } else {
                      print("Data == nil")
                  }
              }
          }
      }
    
    private func decodeData(inputData: Data) -> Array<UInt8>
    {
        var resultArr = Array<UInt8>();
        for i in 0..<inputData.count{
            resultArr.append(inputData[i]);
        }
        return resultArr;
    }

    
    public func beginUDPConnection(secondsToPass: Int) -> Array<UInt8>
    {
        let hostIP = userDefaults.string(forKey: "DeviceIP");
        let hostPort = userDefaults.string(forKey: "DevicePort");
        if(hostIP == "NOT SET" || hostPort == "NOT SET" || hostIP == nil || hostPort == nil)
        {
            print("ERROR");
            return Array<UInt8>();
        }
        else
        {
            let hostUDP: Network.NWEndpoint.Host = .init(hostIP!)
            connectToUDP(hostUDP, NWEndpoint.Port(hostPort!)!, measurements: secondsToPass * 2);
            return self.receivedData;
        }
    }
    
    public func getResult() -> Array<UInt8>
    {
        return self.receivedData;
    }
    
    public func endUDPConnection()
    {
        sendUDP("####");
        print("STOPPING CONNECTION")
    }

    public func connectToWifi() {
        let wifiSSID = userDefaults.string(forKey: "DeviceWifi")
        let wifiPassword = userDefaults.string(forKey: "DeviceWifiPassword")
        if(wifiSSID == "NOT SET" || wifiPassword == "NOT SET" || wifiSSID == nil || wifiPassword == nil)
        {
            
        }
        else{
            let wifiConfiguration = NEHotspotConfiguration(ssid: wifiSSID!, passphrase: wifiPassword!, isWEP: false)
            
            NEHotspotConfigurationManager.shared.apply(wifiConfiguration) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
                else{
//                    user confirmation for connecting to wifi received
                }
            }
        }
    }
    
}
