//
//  MeasurmentsView.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 14/05/2021.
//

import UIKit

class MeasurmentsView: UIViewController {

    var filesHandler = CustomFilesHandler();
    var viewModel: FilesHandlerViewModel!
    var pathToDocumentsDir: String = "";
    
    @IBAction func handleExitMeasurements(_ segue:UIStoryboardSegue)
    {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /* NOTE
     THIS IS A TEMPORARY LOCATION OF THIS METHOD IN ORDERT TO SHOW THAT FILES CREATION WORKS
     */
    
    @IBAction func startMeasurements(_ sender: Any)
    {
        let now = getCurrentTime();
        //DO MEASURING MAGIC
        
        
        //END MEASURING MAGIC
        filesHandler.saveDataBatch(dataToSave: <#T##String#>, timeOfMeasurement: now)
//        let fileName = now + "_Measurement_" + "A"
//        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
////        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("myFile")
//        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
//        print("FilePath: \(fileURL.path)")
//
//        let fileTemporaryContent = "Lorem ipsume etcetera etiam eget nunc non nisl tincidunt fermentum. Phasellus congue."
//
//        do {
//            try fileTemporaryContent.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
//        }
//        catch let error as NSError
//        {
//            print("Failed to write to file to URL: \(fileURL), Error: " + error.localizedDescription)
//        }
        
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
