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
    var labelTimer = Timer();
//    var countDownTimer = Timer();
    var timeLeft = 0;
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
        
//        self.timeLeft = timeTargetInMinutes * 60;
        let now = getCurrentTime();
        //DO MEASURING MAGIC
        
        //GET DATA HERE
//        var receivedData = wifiHandler.beginUDPConnection(timer);
        /*
         [164, 209, 14, 51, 141, 178, 191, 47, 187, 228, 159, 174, 180, 142, 250, 42, 159, 122, 46, 175, 201, 153, 61, 47, 134, 115, 12, 187, 61, 4, 133, 155, 23, 214, 33, 212, 74, 17, 242, 26, 11, 245, 150, 167, 144, 182, 145, 248, 153, 106, 103, 223, 140, 221, 159, 126, 160, 44, 195, 235, 132, 251, 203, 15, 79, 230, 250, 46, 186, 49, 48, 120, 124, 154, 238, 24, 122, 162, 21, 194, 38, 71, 159, 157, 234, 222, 84, 74, 215, 120, 67, 227, 224, 195, 119, 185, 209, 3, 35, 19, 153, 6, 192, 192, 99, 242, 117, 53, 43, 1, 16, 10, 209, 139, 186, 36, 79, 11, 237, 154, 36, 126, 169, 24, 249, 203, 109, 216, 0, 0, 171, 172, 173, 174, 171, 170, 111, 250, 134, 88, 252, 20, 36, 7, 177, 12, 29, 33, 31, 69, 56, 51, 167, 9, 201, 105, 219, 51, 146, 129, 159, 39, 88, 112, 123, 50, 28, 251, 21, 236, 31, 12, 251, 161, 249, 131, 86, 179, 177, 150, 186, 13, 49, 208, 65, 56, 50, 157, 11, 95, 114, 156, 145, 67, 127, 254, 12, 128, 231, 103, 159, 201, 173, 96, 231, 69, 53, 123, 59, 1, 161, 216, 23, 254, 219, 68, 178, 232, 137, 157, 33, 206, 165, 236, 210, 76, 228, 177, 227, 161, 209, 90, 210, 101, 229, 64, 221, 73, 214, 81, 183, 132, 158, 113, 180, 106, 229, 161, 224, 113, 110, 55, 131, 155, 12, 83, 9, 79, 128, 104, 60, 168, 31, 179, 0, 1, 171, 172, 173, 174, 171, 170, 119, 248, 98, 244, 250, 21, 19, 223, 221, 223, 222, 218, 24, 6, 86, 45, 30, 20, 226, 182, 214, 63, 167, 227, 177, 214, 147, 19, 152, 60, 23, 212, 56, 225, 20, 55, 75, 158, 17, 64, 131, 97, 208, 0, 55, 173, 178, 108, 119, 137, 202, 215, 185, 56, 236, 249, 83, 213, 3, 162, 13, 218, 116, 245, 246, 139, 47, 70, 90, 162, 154, 127, 99, 72, 176, 184, 123, 57, 169, 228, 54, 224, 255, 152, 126, 34, 210, 25, 27, 84, 58, 19, 219, 140, 23, 131, 181, 28, 190, 14, 136, 215, 163, 70, 74, 179, 52, 223, 50, 240, 204, 158, 111, 99, 29, 206, 91, 20, 65, 134, 188, 157, 244, 80, 68, 4, 168, 209, 0, 2, 171, 172, 173, 174, 171, 170, 205, 255, 168, 174, 207, 199, 76, 136, 18, 239, 161, 228, 38, 111, 251, 222, 212, 199, 100, 80, 88, 173, 37, 39, 43, 120, 241, 159, 83, 115, 33, 191, 148, 116, 128, 224, 176, 41, 98, 249, 7, 18, 240, 174, 121, 165, 122, 20, 86, 14, 18, 39, 197, 244, 212, 231, 248, 49, 166, 41, 229, 15, 12, 151, 27, 40, 142, 127, 116, 249, 200, 111, 8, 91, 80, 193, 251, 104, 137, 3, 39, 104, 53, 70, 96, 33, 110, 119, 252, 45, 112, 183, 213, 213, 178, 19, 193, 129, 61, 192, 104, 65, 69, 234, 49, 185, 231, 54, 165, 126, 24, 166, 118, 213, 56, 17, 180, 20, 196, 32, 56, 156, 255, 179, 77, 26, 223, 54, 0, 3, 171, 172, 173, 174, 171, 170, 238, 118, 135, 226, 81, 203, 20, 11, 181, 230, 202, 63, 63, 208, 222, 201, 75, 179, 45, 210, 161, 244, 87, 104, 61, 103, 168, 241, 0, 253, 76, 213, 62, 132, 185, 41, 169, 102, 51, 92, 21, 141, 253, 224, 79, 161, 254, 255, 98, 98, 93, 130, 113, 169, 114, 132, 244, 122, 104, 94, 243, 185, 163, 86, 194, 184, 137, 74, 103, 110, 173, 64, 106, 149, 146, 175, 88, 16, 235, 107, 138, 177, 78, 23, 168, 151, 34, 82, 29, 89, 254, 62, 238, 200, 84, 23, 23, 63, 78, 197, 102, 83, 66, 2, 60, 96, 241, 52, 138, 245, 18, 110, 129, 78, 24, 93, 229, 226, 200, 215, 247, 231, 51, 225, 146, 131, 199, 24, 0, 4, 171, 172, 173, 174, 171, 170, 104, 176, 162, 9, 239, 247, 23, 85, 245, 76, 206, 30, 248, 206, 249, 231, 194, 187, 120, 45, 138, 229, 118, 96, 106, 46, 159, 109, 195, 228, 94, 160, 80, 200, 130, 63, 112, 53, 230, 125, 125, 49, 51, 84, 170, 154, 80, 4, 200, 177, 121, 77, 249, 60, 101, 193, 43, 238, 76, 67, 46, 86, 75, 0, 28, 245, 115, 161, 116, 185, 39, 169, 133, 209, 113, 10, 114, 191, 241, 210, 217, 181, 35, 151, 206, 239, 21, 249, 12, 245, 108, 124, 13, 4, 207, 225, 234, 239, 150, 55, 56, 0, 3, 62, 150, 93, 159, 232, 65, 137, 171, 23, 101, 252, 174, 148, 219, 150, 193, 57, 23, 19, 162, 128, 22, 150, 40, 135, 0, 5, 171, 172, 173, 174, 171, 170, 106, 86, 211, 112, 10, 95, 160, 231, 177, 67, 153, 169, 254, 102, 54, 197, 52, 44, 253, 202, 167, 97, 151, 143, 242, 188, 126, 199, 206, 52, 99, 77, 84, 188, 113, 212, 24, 143, 246, 88, 100, 50, 233, 191, 233, 66, 134, 87, 180, 181, 236, 236, 101, 251, 96, 86, 110, 215, 118, 4, 62, 245, 12, 200, 41, 18, 23, 76, 107, 79, 182, 164, 5, 82, 41, 144, 238, 209, 70, 82, 10, 198, 190, 43, 43, 252, 51, 176, 46, 182, 206, 152, 217, 164, 17, 48, 194, 175, 253, 57, 158, 149, 173, 99, 169, 246, 125, 85, 191, 154, 176, 84, 14, 112, 68, 214, 77, 118, 18, 76, 39, 115, 202, 67, 105, 211, 142, 225, 0, 6, 171, 172, 173, 174, 171, 170, 88, 66, 76, 146, 209, 230, 223, 21, 218, 249, 111, 1, 115, 172, 183, 73, 21, 29, 162, 211, 7, 145, 118, 247, 149, 90, 153, 117, 116, 141, 38, 128, 163, 50, 188, 64, 205, 5, 114, 115, 8, 240, 43, 131, 172, 164, 48, 0, 2, 129, 25, 100, 22, 0, 202, 224, 68, 202, 105, 74, 106, 226, 93, 109, 188, 189, 25, 105, 93, 251, 228, 70, 31, 11, 36, 166, 20, 180, 128, 90, 94, 62, 251, 199, 174, 234, 33, 249, 70, 72, 19, 161, 130, 199, 156, 149, 251, 9, 206, 182, 165, 221, 145, 141, 38, 84, 70, 226, 99, 136, 80, 218, 64, 220, 189, 226, 173, 198, 10, 50, 68, 254, 153, 208, 91, 25, 241, 157, 0, 7, 171, 172, 173, 174, 171, 170, 29, 236, 70, 171, 122, 85, 113, 52, 140, 47, 69, 247, 82, 5, 111, 180, 52, 236, 217, 16, 141, 254, 188, 175, 143, 242, 151, 33, 98, 216, 177, 94, 193, 0, 156, 174, 72, 236, 32, 151, 38, 191, 245, 182, 178, 138, 66, 70, 0, 158, 78, 117, 82, 233, 220, 254, 82, 104, 54, 144, 232, 167, 42, 131, 166, 146, 240, 254, 32, 143, 99, 58, 87, 200, 46, 45, 214, 75, 128, 181, 7, 8, 95, 240, 177, 240, 94, 111, 77, 207, 233, 220, 85, 189, 115, 243, 93, 207, 84, 227, 195, 166, 32, 19, 139, 32, 82, 36, 23, 244, 64, 209, 232, 127, 39, 220, 222, 208, 92, 120, 128, 126, 28, 99, 254, 230, 197, 222, 0, 8, 171, 172, 173, 174, 171, 170, 93, 73, 31, 13, 2, 251, 243, 88, 152, 86, 46, 229, 105, 40, 64, 105, 149, 17, 123, 19, 80, 42, 231, 1, 87, 32, 91, 222, 191, 119, 109, 53, 66, 92, 2, 235, 54, 141, 213, 204, 32, 176, 137, 124, 179, 16, 163, 219, 125, 13, 113, 204, 204, 103, 47, 166, 44, 104, 235, 252, 211, 254, 0, 46, 213, 150, 249, 226, 142, 4, 86, 150, 177, 179, 67, 82, 82, 2, 180, 217, 72, 58, 136, 192, 36, 33, 96, 235, 201, 244, 102, 168, 190, 144, 191, 61, 20, 87, 98, 43, 62, 34, 174, 147, 26, 224, 131, 99, 138, 14, 77, 128, 213, 143, 254, 189, 71, 81, 236, 105, 47, 191, 227, 184, 251, 81, 184, 65, 0, 9, 171, 172, 173, 174, 171, 170]
         */
        
        //END MEASURING MAGIC
        
        //ALSO BY THE USE OF MAGIC SOMEHOW DISPLAY THIS DATA ON A CHART
        
        if !isTimerOn
        {
            labelTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementTimer), userInfo: nil, repeats: true)
            isTimerOn = true
        }
        
//        let receivedData = wifiHandler.beginUDPConnection(secondsToPass: self.timeTargetInMinutes * 60);
        let receivedData = self.test();
        
        print("RECEIVED DATA FROM WIFI HANDLER: ")
        print(receivedData)
        filesHandler.saveDataBatch(dataToSave: "LoremIpsumPLACEHOLDER", timeOfMeasurement: now);
        
        
    }
    
    func test() -> Array<UInt8>
    {
        let semaphore = DispatchSemaphore(value: 0)
//        let result = wifiHandler.beginUDPConnection(secondsToPass: self.timeTargetInMinutes * 60, semaphorerere: semaphore);
        wifiHandler.beginUDPConnection(secondsToPass: self.timeTargetInMinutes * 60, semaphorerere: semaphore);
        semaphore.wait();
        let result = wifiHandler.getResult();
        return result;
        
    }
    
    @objc func incrementTimer()
    {
        //TODO: change to +=1
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
    
//    @objc func decremnt
    
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
    
    
    @IBAction func handleExitMeasurements(_ segue:UIStoryboardSegue)
    {
        
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
