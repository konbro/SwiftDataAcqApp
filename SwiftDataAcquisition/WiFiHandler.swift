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
    let beginTransmissionMsg = "****"
    let endTransmissionMsg = "####"
    
    var caller: MeasurmentsView!
    var selectedProtocol: String;
    var connection: NWConnection?
    var hostUDP: Network.NWEndpoint.Host = ""
    
    var receivedData = Array<UInt8>();
    var receivedDataDecoded = Array<UInt16>();

    //    initializer and setters
    init()
    {
        caller = nil;
        selectedProtocol = "TCP"
    }
    public func setCaller(calledFrom: MeasurmentsView)
    {
        caller = calledFrom;
    }
    public func setProtocol(pickedProtocol: String)
    {
        selectedProtocol = pickedProtocol;
        caller.showAlert(title: "Protocol selected", errormsg: "Currently selected protocol is: \(selectedProtocol)")
        
    }
    
    func stopConnection() {
        self.startSend(message: "####")
        self.connection?.cancel()
        NSLog("did stop")
    }
    
    public func startConnection()
    {
        NSLog("Attempting to start connection")
        self.connection?.stateUpdateHandler = self.didChange(state:)
        self.startSend(message: "****")
        self.startReceive()
        self.connection?.start(queue: .main)
    }
    
    private func didChange(state: NWConnection.State)
    {
        switch state
        {
            case .ready:
                NSLog("Connection is ready")
                
            case .setup:
                print("State: Setup\n")
                
            case .waiting(let error):
                NSLog("is waiting: %@", "\(error)")
                
            case .cancelled:
                NSLog("was cancelled")
                print("State: Cancelled\n")
                self.stopConnection()
                
            case .failed(let error):
                NSLog("did fail, error: %@", "\(error)")
                self.stopConnection()
                
            case .preparing:
                print("State: Preparing\n")
                
            default:
                print("ERROR! State not defined!\n")
        }
        
    }
    
    private func startReceive()
    {
        self.connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) {
            data, _, isDone, error in
            if let data = data, !data.isEmpty {
                NSLog("Received data: \(data)")
                let decodedData = self.appendData(inputData: data)
                let decodedDataMSB = self.decodeData(inputData: decodedData)
                self.receivedDataDecoded.append(contentsOf: decodedDataMSB);
                self.receivedData.append(contentsOf: decodedData);
            }
            if let error = error {
                NSLog("Did receive, ERROR: %@", "\(error)")
                self.stopConnection()
                return
            }
            if isDone {
                NSLog("did receive, EOF")
               self.stopConnection()
               return
            }
        }
    }
    
    private func startSend(message: String)
    {
        let data = Data(message.utf8)
        self.connection?.send(content: data, completion: NWConnection.SendCompletion.contentProcessed {
            error in
            if let error = error
            {
                NSLog("did send, error: %@", "\(error)")
                self.stopConnection()
            } else
            {
                NSLog("did send, data: %@", data as NSData)
            }
        })
    }
    
    //MARK:- UDP
    func connectToHost(_ networkHost: Network.NWEndpoint.Host, _ networkHostPort: Network.NWEndpoint.Port, measurements: Int)
    {
        let messageToHost = "****"
        if selectedProtocol == "TCP"
        {
            self.connection = NWConnection(host: networkHost, port: networkHostPort, using: .tcp)
        }
        else
        {
            self.connection = NWConnection(host: networkHost, port: networkHostPort, using: .udp)
        }
        self.connection?.stateUpdateHandler =
        { (newState) in
            print("This is stateUpdateHandler:")
            switch (newState)
            {
                case .ready:
                print("State: Ready\n")
                self.sendUDP(messageToHost)
                for _ in 0...measurements
                {
                    self.receiveUDP()
                }
                case .setup:
                    print("State: Setup\n")
                case .waiting(let error):
                    NSLog("is waiting: %@", "\(error)")
                case .cancelled:
                    NSLog("was cancelled")
                    print("State: Cancelled\n")
                    self.stopConnection()
                case .failed(let error):
                    NSLog("did fail, error: %@", "\(error)")
                    self.stopConnection()
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
                  print("Data was sent to host")
                 DispatchQueue.main.async { print("Data was sent to host") }
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
                    let decodedData = self.appendData(inputData: data!)
                    let decodedDataMSB = self.decodeData(inputData: decodedData)
                    self.receivedDataDecoded.append(contentsOf: decodedDataMSB);
                    self.receivedData.append(contentsOf: decodedData);
                  } else {
                      print("Data == nil")
                  }
              }
          }
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
            self.connectToHost(hostUDP, NWEndpoint.Port(hostPort!) ?? 80, measurements: secondsToPass * 2);
            
            return self.receivedData;
        }
    }

    public func endUDPConnection()
    {
        sendUDP("####");
        print("STOPPING UDP CONNECTION")
    }
    
    private func appendData(inputData: Data) -> Array<UInt8>
    {
        var resultArr = Array<UInt8>();
        for i in 0..<inputData.count{
            resultArr.append(inputData[i]);
        }
        return resultArr;
    }
    
    private func decodeData(inputData: Array<UInt8>) -> Array<UInt16>
    {
        var resultArr = Array<UInt16>();
        var tmpUInt16 = UInt16();
        for i in stride(from: 0, to: inputData.count, by: 2){
            tmpUInt16 = UInt16(inputData[i]);
            tmpUInt16 = tmpUInt16 << 8;
            tmpUInt16 = tmpUInt16|UInt16(inputData[i+1]);
            resultArr.append(tmpUInt16);
        }
        return resultArr;
    }

    
    public func getResult() -> Array<UInt8>
    {
        return self.receivedData;
    }
    


    public func connectToWifi() throws {
        var wifiConfiguration: NEHotspotConfiguration;
        let wifiSSID = userDefaults.string(forKey: "DeviceWiFi")
        let wifiPassword = userDefaults.string(forKey: "DeviceWiFiPassword")
        if(wifiSSID == "NOT SET" || wifiSSID == nil)
        {
            throw WiFiHanlderError.wifiNetworkNotSet;
        }
        if(wifiPassword == "NOT SET")
        {
            throw WiFiHanlderError.wifiNetworkPasswordNotSet;
        }
        if(wifiPassword == "")
        {
            wifiConfiguration = NEHotspotConfiguration(ssid: wifiSSID!);
        }
        else
        {
            wifiConfiguration = NEHotspotConfiguration(ssid: wifiSSID!, passphrase: wifiPassword!, isWEP: false)
        }
        NEHotspotConfigurationManager.shared.apply(wifiConfiguration) { error in
        if let error = error{
            print("ERROR CONNECTING TO WIFI")
            print(error.localizedDescription)
                }
            else{
//                    user confirmation for connecting to wifi received
                }
            }
        
    }
}
