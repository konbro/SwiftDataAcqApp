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
    let transmissionMsgStart = "****"
    let transmissionMsgEnd = "####"
    
    var caller: MeasurmentsView!;
    var dataHandler: MeasurementDataModel!;
    var selectedProtocol: String;
    var connection: NWConnection?;
    var hostUDP: Network.NWEndpoint.Host = "";
    
    var frameOffset: Int = 0;
    var frameCurrentIndex: Int = 0;
    var framesMissedCount: Int = 0;
    var receivedData = Array<UInt8>();
    var receivedDataDecoded = Array<UInt16>();
    
    var indexesArr = Array<UInt16>();
    var receivedDataFromMeasuringStations = [[UInt16]]();
    

    //    initializer and setters
    init(measurementDataModel: MeasurementDataModel)
    {
        dataHandler = measurementDataModel;
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
        self.startSend(message: self.transmissionMsgEnd)
        self.connection?.cancel()
        NSLog("did stop")
    }
//
//    public func startConnection()
//    {
//        NSLog("Attempting to start connection")
//        self.connection?.stateUpdateHandler = self.didChange(state:)
//        self.startSend(message: "****")
//        self.startReceive()
//        self.connection?.start(queue: .main)
//    }
//
//    private func didChange(state: NWConnection.State)
//    {
//        switch state
//        {
//            case .ready:
//                NSLog("Connection is ready")
//
//            case .setup:
//                print("State: Setup\n")
//
//            case .waiting(let error):
//                NSLog("is waiting: %@", "\(error)")
//
//            case .cancelled:
//                NSLog("was cancelled")
//                print("State: Cancelled\n")
//                self.stopConnection()
//
//            case .failed(let error):
//                NSLog("did fail, error: %@", "\(error)")
//                self.stopConnection()
//
//            case .preparing:
//                print("State: Preparing\n")
//
//            default:
//                print("ERROR! State not defined!\n")
//        }
//
//    }
//
//    private func startReceive()
//    {
//        self.connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) {
//            data, _, isDone, error in
//            if let data = data, !data.isEmpty {
//                NSLog("Received data: \(data)")
//                let decodedData = self.appendData(inputData: data)
//                let decodedDataMSB = self.decodeData(inputData: decodedData)
//                self.receivedDataDecoded.append(contentsOf: decodedDataMSB);
//                self.receivedData.append(contentsOf: decodedData);
//            }
//            if let error = error {
//                NSLog("Did receive, ERROR: %@", "\(error)")
//                self.stopConnection()
//                return
//            }
//            if isDone {
//                NSLog("did receive, EOF")
//               self.stopConnection()
//               return
//            }
//        }
//    }
//
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
                self.sendUDP(self.transmissionMsgStart)
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
        self.connection?.start(queue: .global())
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
                //check frame counters
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
        self.frameCurrentIndex = 0;
        self.frameOffset = 0;
        self.receivedData.removeAll();
        self.receivedDataDecoded.removeAll();
        
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
        sendUDP(transmissionMsgEnd);
        print("STOPPING UDP CONNECTION")
    }
    
    
    // Data manipulation
    private func appendData(inputData: Data) -> Array<UInt8>
    {
        var resultArr = Array<UInt8>();
        //TODO
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
        var maxValOfI = 0;
        var framesMissedIndexOffset = 0; //TODO make class-wide variable
        for i in stride(from: 64 + (frameOffset), to: resultArr.count, by: 68)
        {
            print(resultArr[i], i, resultArr.count)
            print(resultArr[i+framesMissedIndexOffset], i+framesMissedIndexOffset, "Frames missed index offset: \(framesMissedIndexOffset)")
            var indexWithMissingFrames = i + framesMissedIndexOffset;
            if(indexesArr.count != 0)
            {
                //check if previous found frame index is not smaller by one
                //Rework here needed badly
                if(indexesArr[i-1] != resultArr[i]-1)
                {
                    //ERROR PREVIOUS FRAME VALUE IS WRONG
//                    resultArr.firstIndex(of: 43948)
                    let indexesOf0 = resultArr.enumerated().filter
                    {
                        $0.element == 43948
                    }.map{$0.offset}
                    let indexesOf1 = resultArr.enumerated().filter
                    {
                        $0.element == 44462
                    }.map{$0.offset}
                    let indexesOf2 = resultArr.enumerated().filter
                    {
                        $0.element == 43946
                    }.map{$0.offset}
                    if(indexesOf0.count == indexesOf1.count && indexesOf1.count == indexesOf2.count)
                    {
                        //sizes of found special frame markers match.
                        //perfect would be like:
                        /*
                         indexesOf0[0] = 65
                         indexesOf1[0] = 66
                         indexesOf2[0] = 67
                         
                         then the val at index 64 is our frame counter
                         */
                        /*TODO
                         Add check if those frames are actually next to each other (Possibility of data having value of this flag!!
                        */
                        for flagIndex in indexesOf0
                        {
                            let probableFrameIndex = flagIndex - 1
                            if(probableFrameIndex > i)
                            {
                                //j index is bigger than i
                                if(resultArr[probableFrameIndex] > self.frameCurrentIndex)
                                {
                                    //difference between those indexes should be added to variable which counts missing frames
//                                    i = probableFrameIndex;//NOT A VIABLE METHOD AS i IS A LET CONSTANT
                                    //
                                    self.framesMissedCount += Int(resultArr[probableFrameIndex]) - self.frameCurrentIndex;
                                }
                                break; //end this for loop as we've found our new value of index i
                            }
                            else
                            {
                                continue
                            }
                        }
                    }
                    else
                    {
                        //sad part where we have to do magic and remove elements that don't fit
                    }
                }
                else
                {
                    indexesArr.append(resultArr[i]);
                }
            }
            else
            {
                indexesArr.append(resultArr[i]);
            }
            self.frameCurrentIndex = Int(resultArr[i]);
            maxValOfI = i;
        }
        self.frameOffset = maxValOfI - resultArr.count + 4;
        print(resultArr.count, maxValOfI, self.frameOffset)
        return resultArr;
    }

    // getters
    public func getResultUInt16() -> Array<UInt16>
    {
        return self.receivedDataDecoded;
    }
    
    public func getResult() -> Array<UInt8>
    {
        return self.receivedData;
    }
    
    public func getCurrentFrameCount() -> Int
    {
        return self.frameCurrentIndex;
    }
    

// Disabled due to apple's stupid policy
//    public func connectToWifi() throws {
//        var wifiConfiguration: NEHotspotConfiguration;
//        let wifiSSID = userDefaults.string(forKey: "DeviceWiFi")
//        let wifiPassword = userDefaults.string(forKey: "DeviceWiFiPassword")
//        if(wifiSSID == "NOT SET" || wifiSSID == nil)
//        {
//            throw WiFiHandlerError.wifiNetworkNotSet;
//        }
//        if(wifiPassword == "NOT SET")
//        {
//            throw WiFiHandlerError.wifiNetworkPasswordNotSet;
//        }
//        if(wifiPassword == "")
//        {
//            wifiConfiguration = NEHotspotConfiguration(ssid: wifiSSID!);
//        }
//        else
//        {
//            wifiConfiguration = NEHotspotConfiguration(ssid: wifiSSID!, passphrase: wifiPassword!, isWEP: false)
//        }
//        NEHotspotConfigurationManager.shared.apply(wifiConfiguration) { error in
//        if let error = error{
//            print("ERROR CONNECTING TO WIFI")
//            print(error.localizedDescription)
//                }
//            else{
////                    user confirmation for connecting to wifi received
//                }
//            }
//
//    }
    
}
