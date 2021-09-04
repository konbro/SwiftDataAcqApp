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
    
    @IBAction func TimeSliderValueChanged(_ sender: UISlider) {
        print("VALUE: \(sender.value) ROUNDED: \(sender.value.rounded())")
        var minutesCount = String(Int(sender.value.rounded()));
        minutesCount.append(":00");
        TimeTargetLabel.text = minutesCount
    }
    
    let filesHandler = CustomFilesHandler();
    var viewModel: FilesHandlerViewModel!
    var pathToDocumentsDir: String = "";
    let userDefaults = UserDefaults.standard;
    var timer = Timer()
    var seconds = 0
    var isTimerOn = false
    
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
        let now = getCurrentTime();
        //DO MEASURING MAGIC
        
        //GET DATA HERE
        
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
        seconds += 1
        MeasurementTimeLabel.text = "\(seconds)"
        
    }
    
    @IBAction func handleExitMeasurements(_ segue:UIStoryboardSegue)
    {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seconds = 0;
        timer.invalidate();
        isTimerOn = false;
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
