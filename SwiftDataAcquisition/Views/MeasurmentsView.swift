//
//  MeasurmentsView.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 14/10/2021.
//

import UIKit

class MeasurmentsView: UIViewController {
    
    @IBOutlet weak private var MeasurementTimeLabel: UILabel!
    
    @IBOutlet weak private var TimeTargetLabel: UILabel!
    
    @IBOutlet weak var FramesCountLabel: UILabel!
    
    @IBOutlet weak private var TimeSlider: UISlider!
    
    @IBOutlet weak private var StopTransmissionBtn: UIButton!
    
    @IBOutlet weak private var StartMeasurementBtn: UIButton!
    
    @IBOutlet weak private var ProtocolSelectBtn: UIButton!

    @IBOutlet weak var ShowGraphBtn: UIButton!
    
    let filesHandler = CustomFilesHandler();
    let dataHandler = MeasurementDataModel();
    let wifiHandler: WiFiHandler!;
    var pathToDocumentsDir: String = "";
    var selectedMeasurementStation = 0;
    let userDefaults = UserDefaults.standard;
    var labelTimer = Timer();
    var timeLeft = 0;
    var seconds = 0;
    var timeTargetInMinutes = 0;
    var isTimerOn = false;
    var selectedProtocol = "TCP"
    var timer = Timer()
    var measurementStarted = false;
//    var isTimerOn = false
    
    required init(coder: NSCoder) {
        wifiHandler = WiFiHandler(measurementDataModel: self.dataHandler);
        super.init(coder: coder)!;
        wifiHandler.setCaller(calledFrom: self)
        
    }
    
    @IBAction func handleExit(_ segue:UIStoryboardSegue)
    {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "chartsSegue"
        {
            var indexes = Array<Int>();
            for i in 0...64
            {
                indexes.append(i);
            }
            //TODO
            //periodically update the chart via getting values from dataHandler
//            let (_, stationsValues) = dataHandler.getIndexesAndValues(); //commented for debugging
            let destination = segue.destination as! ChartsView;
            destination.barchartXAxisData = indexes;
            destination.dataHandler = self.dataHandler;
        }
    }
    
    @IBAction func toggleProtocol(sender: UIButton)
    {
//        wifiHandler.callAlert()
        if selectedProtocol == "TCP"
        {
            selectedProtocol = "UDP"
        }
        else
        {
            selectedProtocol = "TCP"
        }
        wifiHandler.setProtocol(pickedProtocol: selectedProtocol)
        sender.setTitle(selectedProtocol, for: .normal)
    }
    
    
    @IBAction func TimeSliderValueChanged(_ sender: UISlider) {
        print("VALUE: \(sender.value) ROUNDED: \(sender.value.rounded())")
        var minutesCount = String(Int(sender.value.rounded()));
        timeTargetInMinutes = Int(minutesCount)!;
        minutesCount.append(":00");
        TimeTargetLabel.text = minutesCount;
        if(sender.value != 0)
        {
            StartMeasurementBtn.isEnabled = true;
        }
        else
        {
            StartMeasurementBtn.isEnabled = false;
        }
    }
    

    @IBAction func startMeasurementsBtnPressed(_ sender: Any)
    {
        self.ShowGraphBtn.isEnabled = true;
        do {
//            try wifiHandler.connectToWifi();
            StopTransmissionBtn.isEnabled = true;
            StartMeasurementBtn.isEnabled = false;
            TimeSlider.isEnabled = false;
            
            let now = getCurrentTime();
            
            //END MEASURING MAGIC
            
            if !isTimerOn
            {
                labelTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementTimer), userInfo: nil, repeats: true)
                isTimerOn = true
            }
        
            let delaySeconds = timeTargetInMinutes * 60;
            let dispatchAfter = DispatchTimeInterval.seconds(delaySeconds)
            
            //begin new WiFi UDP connection
            let _ = wifiHandler.beginUDPConnection(secondsToPass: delaySeconds);
//            wifiHandler.startConnection();
            
            print("Started connection via: \(selectedProtocol)")
            print("Connecting to:" + userDefaults.string(forKey: "DeviceIP")!)
            
            var receivedData = [UInt8]();
            var receivedDataDecoded = [UInt16]();
            //wait for connection to finish before getting data from wifiHandler
            //HOW TO RUN THIS WHEN STOP button is pressed?
            DispatchQueue.main.asyncAfter(deadline: .now() + dispatchAfter)
            {
                self.wifiHandler.endUDPConnection();
                receivedData = self.wifiHandler.getResult();
                receivedDataDecoded = self.wifiHandler.getResultUInt16();
                print("RECEIVED DATA FROM WIFI");
                print(receivedDataDecoded);
                //REMEMBER TO UNCOMMENT THIS
                self.filesHandler.saveDataBatch(dataToSave: receivedData, timeOfMeasurement: now);
            }
            print("async work in progress...");
        }
        catch WiFiHandlerError.wifiNetworkPasswordNotSet
        {
            showAlert(title:"Configuration error", errormsg: "Wifi password is not defined. Please go to settings screen to set missing password")
        }
        catch WiFiHandlerError.wifiNetworkNotSet
        {
            showAlert(title:"Configuration error", errormsg: "Wifi SSID is not defined. Please go to settings screen to set missing SSID")
        }
        catch
        {
            
        }
//            }
        
    }
    
    @IBAction func StopBtnPressed(_ sender: UIButton)
    {
        print("MANUAL END OF MEASUREMENT");
        wifiHandler.endUDPConnection();
//        wifiHandler.stopConnection();
        self.showAlert(title: "Measurement stopped", errormsg: "User has cancelled measurement manually")
        resetView()
    }
    
    /**
     - Parameter title: title of alert that should be shown to user
     - Parameter errormsg: description that should be shown to user
     */
    public func showAlert(title: String, errormsg: String)
    {
        //showing an alert to user with given title and msg
        let alert = UIAlertController(title: title, message: errormsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateFrameCounter(frameCount: Int)
    {
        self.FramesCountLabel.text = String(frameCount);
    }
    
    @objc func incrementTimer()
    {
        seconds += 1
        let (_, minutesCount, secondsCount) = secondsToHoursMinutesSeconds(seconds: seconds);
        MeasurementTimeLabel.text = "\(minutesCount):\(secondsCount)"
//        var frameCount = self.wifiHandler.getCurrentFrameCount()
        let frameCount = self.dataHandler.getLastFrameIndex();
        self.FramesCountLabel.text = String(frameCount)
        if(seconds >= timeTargetInMinutes * 60)
        {
            print("AUTOMATIC END OF MEASUREMENT");
            wifiHandler.endUDPConnection();
            self.showAlert(title: "Measuerement is finished", errormsg: "Measurement time has passed and is finished")
            resetView()
        }
        
    }
    
    private func resetView()
    {
        StopTransmissionBtn.isEnabled = false;
        StartMeasurementBtn.isEnabled = true;
        TimeSlider.isEnabled = true;
        seconds = 0;
        isTimerOn = false;
        labelTimer.invalidate();
        MeasurementTimeLabel.text = "00:00"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        StartMeasurementBtn.setTitleColor(.darkGray, for: .disabled);
        StopTransmissionBtn.setTitleColor(.darkGray, for: .disabled);
        seconds = 0;
        labelTimer.invalidate();
        isTimerOn = false;
        labelTimer.invalidate();
    }
    
    //hours, minutes, seconds
    private func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int)
    {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    /**
     This method gets time when called
     
     - Returns: A new string with time of call
     */
    private func getCurrentTime() -> String
    {
        let date = DateFormatter()
        date.dateFormat = "yyyy-MM-dd_hh-mm-ss"
        return date.string(from: Date())
    }
     
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
