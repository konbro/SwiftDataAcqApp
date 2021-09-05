//
//  MeasurmentsView.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 14/05/2021.
//

import UIKit

class MeasurmentsView: UIViewController {

//    @IBOutlet var tableView: UITableView!
    
    
    @IBOutlet weak var FramesCounterLabel: UILabel!
    
    @IBOutlet weak var LostFramesCounterLabel: UILabel!
    
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
    var timer = Timer();
    var seconds = 0;
    var timeTargetInMinutes = 0;
    var isTimerOn = false;
    
    /*
     Measurement timer:
     if !isTimerOn
     {
         timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
         isTimerOn = true
     }
     */
    
    @IBAction func startMeasurements(_ sender: Any)
    {
        StopTransmissionBtn.isEnabled = true;
        StartMeasurementBtn.isEnabled = false;
        TimeSlider.isEnabled = false;
        
        let now = getCurrentTime();
        //DO MEASURING MAGIC
        
        //GET DATA HERE
        var receivedData = wifiHandler.beginUDPConnection();
        
        //END MEASURING MAGIC
        
        //ALSO BY THE USE OF MAGIC SOMEHOW DISPLAY THIS DATA ON A CHART
        
        if !isTimerOn
        {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementTimer), userInfo: nil, repeats: true)
            isTimerOn = true
        }
        filesHandler.saveDataBatch(dataToSave: "LoremIpsumPLACEHOLDER", timeOfMeasurement: now);
        
        
    }
    
    @objc func incrementTimer()
    {
        seconds += 10
        let (_, minutesCount, secondsCount) = secondsToHoursMinutesSeconds(seconds: seconds);
        MeasurementTimeLabel.text = "\(minutesCount):\(secondsCount)"
        if(seconds >= timeTargetInMinutes * 60)
        {
            print("AUTOMATIC END OF MEASUREMENT");
            wifiHandler.endUDPConnection();
            StopTransmissionBtn.isEnabled = false;
            StartMeasurementBtn.isEnabled = true;
            TimeSlider.isEnabled = true;
            seconds = 0;
            isTimerOn = false;
            timer.invalidate()
            MeasurementTimeLabel.text = "00:00"
        }
        
    }
    
    @IBAction func StopBtnPressed(_ sender: UIButton) {
        print("MANUAL END OF MEASUREMENT");
        wifiHandler.endUDPConnection();
        StopTransmissionBtn.isEnabled = false;
        StartMeasurementBtn.isEnabled = true;
        TimeSlider.isEnabled = true;
        seconds = 0;
        isTimerOn = false;
        timer.invalidate();
    }
    
    
    @IBAction func handleExitMeasurements(_ segue:UIStoryboardSegue)
    {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StartMeasurementBtn.setTitleColor(.darkGray, for: .disabled);
        StopTransmissionBtn.setTitleColor(.darkGray, for: .disabled);
        seconds = 0;
        timer.invalidate();
        isTimerOn = false;
        timer.invalidate();
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
