//
//  WiFiHandler.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 04/09/2021.
//

import Foundation

import UIKit
import Network

class WiFiHandler {
     
    let userDefaults = UserDefaults.standard;
    
    var connection: NWConnection?
//    var hostUDP: NWEndpoint.Host = "192.168.4.1"
    var hostUDP: NWEndpoint.Host = ""
//    var portUDP: NWEndpoint.Port = 4210
    
    //MARK:- UDP
      func connectToUDP(_ hostUDP: NWEndpoint.Host, _ portUDP: NWEndpoint.Port) {
          // Transmited message:
       
        let messageToUDP = "****"
//        let options = NWProtocolUDP.Options();
//        options.connectionTimeout = 2;
        
          self.connection = NWConnection(host: hostUDP, port: portUDP, using: .udp)
          self.connection?.stateUpdateHandler = { (newState) in
              print("This is stateUpdateHandler:")
              switch (newState) {
                  case .ready:
                    print("State: Ready\n")
                    self.sendUDP(messageToUDP)
                    for _ in 0...1000{
                        self.receiveUDP()
                    }
//                    self.sendUDP("####")
//                      self.receiveUDP()
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

          self.connection?.start(queue: .global())
      }

      func sendUDP(_ content: Data) {
          self.connection?.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
              if (NWError == nil) {
                  print("Data was sent to UDP")
              } else {
                  print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
              }
          })))
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
                
                 DispatchQueue.main.async {
                    print("Receive is complete")
                    
                 }
                  if (data != nil) {
                    let backToString = String(decoding: data!, as: UTF8.self);
                    let decodedData = self.decodeData(inputData: data!)
                    print("DECODED: \(decodedData)");
                    DispatchQueue.main.async { print(backToString) }
                    
                  } else {
                      print("Data == nil")
                  }
              }
//            return decodedData;
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

    
    public func beginUDPConnection() -> String
    {
        var tmp = userDefaults.string(forKey: "DeviceIP");
        if(tmp == "NOT SET")
        {
            print("ERROR");
            return "ERROR";
        }
        else
        {
            var hostUDP: NWEndpoint.Host = .init(tmp!)
            connectToUDP(hostUDP, 80)
            return "test";
        }
    }
    
    public func endUDPConnection()
    {
        sendUDP("####");
        print("STOPPING CONNECTION")
    }
}
