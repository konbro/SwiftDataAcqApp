//
//  MeasurmentsView.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 14/05/2021.
//

import UIKit

class MeasurmentsView: UIViewController {
    
    @IBOutlet weak var MeasurementTimeLabel: UILabel!
    
    @IBOutlet weak var TimeTargetLabel: UILabel!
    
    @IBOutlet weak var TimeSlider: UISlider!
    
    @IBOutlet weak var StopTransmissionBtn: UIButton!
    
    @IBOutlet weak var StartMeasurementBtn: UIButton!
    
    
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
    
    let filesHandler = CustomFilesHandler();
    let wifiHandler = WiFiHandler();
    var viewModel: FilesHandlerViewModel!
    var pathToDocumentsDir: String = "";
    let userDefaults = UserDefaults.standard;
    var labelTimer = Timer();
    var timeLeft = 0;
    var seconds = 0;
    var timeTargetInMinutes = 0;
    var isTimerOn = false;
    
    @IBAction func startMeasurements(_ sender: Any)
    {
        if(userDefaults.string(forKey: "DeviceIP") == nil || userDefaults.string(forKey: "DeviceIP") == "NOT SET" ||
            userDefaults.string(forKey: "DevicePort") == nil || userDefaults.string(forKey: "DevicePort") == "NOT SET")
        {
            showAlert()
        }
        else
            {
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
            var dispatchAfter = DispatchTimeInterval.seconds(delaySeconds)
       
            wifiHandler.beginUDPConnection(secondsToPass: delaySeconds);
            print("CALLED WIFI")
            var receivedData = [UInt8]();
            DispatchQueue.main.asyncAfter(deadline: .now() + dispatchAfter) {
                receivedData = self.wifiHandler.getResult()
                print("RECEIVED DATA FROM WIFI")
                print(receivedData);
                self.filesHandler.saveDataBatch(dataToSave: receivedData, timeOfMeasurement: now);
            }
            print("async work in progress...");
        }
        
    }
    
    private func showAlert()
    {
        let alert = UIAlertController(title: "ERROR", message: "DeviceIP or DevicePort is not defined. Please go to setting screen to set missing value.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func incrementTimer()
    {
        seconds += 1
        let (_, minutesCount, secondsCount) = secondsToHoursMinutesSeconds(seconds: seconds);
        MeasurementTimeLabel.text = "\(minutesCount):\(secondsCount)"
        if(seconds >= timeTargetInMinutes * 60)
        {
            print("AUTOMATIC END OF MEASUREMENT");
            wifiHandler.endUDPConnection();
            resetView()
        }
        
    }
    
    @IBAction func StopBtnPressed(_ sender: UIButton) {
        print("MANUAL END OF MEASUREMENT");
        wifiHandler.endUDPConnection();
        resetView()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StartMeasurementBtn.setTitleColor(.darkGray, for: .disabled);
        StopTransmissionBtn.setTitleColor(.darkGray, for: .disabled);
        seconds = 0;
        labelTimer.invalidate();
        isTimerOn = false;
        labelTimer.invalidate();
    }
    

    
    //hours, minutes, seconds
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
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
